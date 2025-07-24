import evaluator/case_.{
  type Case, type Evaluation, type Report, type Validator, Case, CompileError,
  Invalid, Report, Valid, evaluation_from_bool,
}
import evaluator/llm
import evaluator/project
import given
import gleam/io
import gleam/json
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import simplifile

const context = "
You are a gleam programmer. You write code to satisfy a 'case' given to you.
You output the code directly and it has to be contained in one file.
The first line you output is the first line of code. No code splitting at all.
Do not annotate your code with any comments.
"

pub fn evaluate_case(
  case_: Case,
  validator: Validator,
  model: llm.Model,
) -> Result(#(String, Evaluation), String) {
  let assert Ok(program) =
    llm.prompt(model, system: context, user: case_.contents)

  let program =
    program
    |> string.replace("```gleam", "")
    |> string.replace("```", "")
    |> string.trim()

  io.println(program)

  let pwd = project.tmp_pwd()
  let case_project = project.Project(pwd)
  use <- project.defer(fn() { project.cleanup(case_project) })

  let assert Ok(_) = project.scaffold(case_project)
  list.each(case_.deps, fn(dep) {
    let assert Ok(_) = project.install_dep(case_project, dep)
  })

  let assert Ok(_) = project.main_module(case_project, program)

  let compiles = case project.gleam_build(case_project) {
    Ok(_) -> True
    Error(_) -> False
  }
  use <- given.that(!compiles, return: fn() { Ok(#(program, CompileError)) })
  case project.gleam_run(case_project, ["--no-print-progress", "test"]) {
    Ok(stdout) -> {
      let valid =
        stdout
        |> validator()
        |> evaluation_from_bool
      Ok(#(program, valid))
    }
    Error(_) -> Ok(#(program, Invalid))
  }
}

fn run_case_for_all_models(case_: Case, validator: Validator) {
  use model <- list.map(llm.all_models)
  io.println("Evaluating Model: " <> llm.model_to_identifier(model))
  let assert Ok(#(program, eval)) = evaluate_case(case_, validator, model)
  io.println("")
  Report(case_, program, model, eval)
}

fn make_case_1() -> Case {
  Case(
    title: "Hello World!",
    contents: "A program that outputs 'hello, world!'",
    deps: [],
  )
}

fn validator_1(stdout: String) -> Bool {
  stdout
  |> string.lowercase()
  |> string.trim()
  == "hello, world!"
}

fn make_case_2() -> Case {
  Case(
    title: "Defer",
    contents: "
A program that demonstrates a 'defer' utility function. Write the function called 'defer' that can be used via the gleam `use` syntax.
Demonstrate it by deferring a print of 'hello' and printing '1' before.
",
    deps: [],
  )
}

fn validator_2(stdout: String) -> Bool {
  stdout
  |> string.lowercase()
  |> string.trim()
  == "1\nhello"
}

fn case_and_report_to_html(case_: Case, reports: List(Report)) {
  html.details([], [
    html.summary([], [html.span([], [html.text("Case: " <> case_.title)])]),
    html.div([], {
      use report <- list.map(reports)

      let eval = case report.eval {
        CompileError -> #("eval-red", "compile error!")
        Invalid -> #("eval-red", "valid: false")
        Valid -> #("eval-green", "valid: true")
      }

      html.details([], [
        html.summary([], [
          html.span([], [
            html.text(
              "Implementation: " <> llm.model_to_identifier(report.model),
            ),
          ]),
        ]),
        html.div([], [
          html.pre([], [html.code([], [html.text(report.program)])]),
          html.p([attribute.class(eval.0)], [html.text(eval.1)]),
        ]),
      ])
    }),
  ])
}

pub fn main() {
  io.println("Evaluating Case 1...")

  let case_1 = make_case_1()
  let case_2 = make_case_2()

  // ### Use to generate new reports
  let reports_1 = run_case_for_all_models(case_1, validator_1)
  let reports_2 = run_case_for_all_models(case_2, validator_2)

  let reports = [reports_1, reports_2]
  // ###

  // ### Use to use cached reports
  // let assert Ok(reports_json) = simplifile.read("./reports.json")
  // let assert Ok(reports) =
  //   json.parse(
  //     reports_json,
  //     using: decode.list(decode.list(case_.report_decoder())),
  //   )
  // let assert [reports_1, reports_2] = reports
  // ###

  io.println("Storing Reports as JSON...")

  let generated_json =
    json.array(reports, of: fn(reports) {
      json.array(reports, of: case_.report_to_json)
    })
    |> json.to_string()
  let assert Ok(_) = simplifile.write("./reports.json", generated_json)

  io.println("Generating HTML Report...")

  let html =
    html.html([attribute.lang("en")], [
      html.head([], [
        html.meta([attribute.charset("utf-8")]),
        html.meta([
          attribute.name("viewport"),
          attribute.content("width=device-width, initial-scale=1"),
        ]),
        html.title([], "Gleam LLM Report"),
        html.style([], css_reset),
        html.style([], style),
      ]),
      html.body([], [
        case_and_report_to_html(case_1, reports_1),
        case_and_report_to_html(case_2, reports_2),
      ]),
    ])
    |> element.to_document_string()

  let assert Ok(_) = simplifile.write("./reports.html", html)
}

const style = "
html,body {
  font-family: Arial, sans-serif;
}

.eval-red {
  color: red;
}
.eval-green {
  color: green;
}
"

const css_reset = "
/* Box sizing rules */
*,
*::before,
*::after {
  box-sizing: border-box;
}

/* Prevent font size inflation */
html {
  -moz-text-size-adjust: none;
  -webkit-text-size-adjust: none;
  text-size-adjust: none;
}

/* Remove default margin in favour of better control in authored CSS */
body, h1, h2, h3, h4, p,
figure, blockquote, dl, dd {
  margin-block-end: 0;
}

/* Remove list styles on ul, ol elements with a list role, which suggests default styling will be removed */
ul[role='list'],
ol[role='list'] {
  list-style: none;
}

/* Set core body defaults */
body {
  min-height: 100vh;
  line-height: 1.5;
}

/* Set shorter line heights on headings and interactive elements */
h1, h2, h3, h4,
button, input, label {
  line-height: 1.1;
}

/* Balance text wrapping on headings */
h1, h2,
h3, h4 {
  text-wrap: balance;
}

/* A elements that don't have a class get default styles */
a:not([class]) {
  text-decoration-skip-ink: auto;
  color: currentColor;
}

/* Make images easier to work with */
img,
picture {
  max-width: 100%;
  display: block;
}

/* Inherit fonts for inputs and buttons */
input, button,
textarea, select {
  font-family: inherit;
  font-size: inherit;
}

/* Make sure textareas without a rows attribute are not tiny */
textarea:not([rows]) {
  min-height: 10em;
}

/* Anything that has been anchored to should have extra scroll margin */
:target {
  scroll-margin-block: 5ex;
}
"
