import argv
import evaluator/case_.{
  type Case, type Evaluation, type Report, type Validator, Case, CompileError,
  Invalid, Report, Valid, evaluation_from_bool,
}
import evaluator/constants
import evaluator/constants/tour
import evaluator/llm
import evaluator/project
import given
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/string
import lustre/attribute
import lustre/element
import lustre/element/html
import simplifile

const cache_path = "./priv/_cache/reports.json"

const report_path = "./priv/report.html"

const max_iterations = 3

const usage = "Usage:
  gleam run
  gleam run cache
"

pub fn main() {
  let case_1 = make_case_1()
  let case_2 = make_case_2()
  let case_3 = make_case_3()

  let reports = case argv.load().arguments {
    ["cache"] -> {
      let assert Ok(reports_json) = simplifile.read(cache_path)
      let assert Ok(reports) =
        json.parse(
          reports_json,
          using: decode.list(decode.list(case_.report_decoder())),
        )
      reports
    }
    [] -> {
      let reports_1 = run_case_for_all_models(case_1, validator_1)
      let reports_2 = run_case_for_all_models(case_2, validator_2)
      let reports_3 = run_case_for_all_models(case_3, validator_3)
      [reports_1, reports_2, reports_3]
    }
    _ -> {
      io.println(usage)
      panic as "unknown argument"
    }
  }

  let assert [reports_1, reports_2, reports_3] = reports

  io.println("Storing Reports as JSON...")

  let generated_json =
    json.array(reports, of: fn(reports) {
      json.array(reports, of: case_.report_to_json)
    })
    |> json.to_string()
  let assert Ok(_) = simplifile.write(cache_path, generated_json)

  io.println("Generating HTML Report...")

  let cases_and_reports = [
    #(case_1, reports_1),
    #(case_2, reports_2),
    #(case_3, reports_3),
  ]
  let html = generate_html(cases_and_reports)

  let assert Ok(_) = simplifile.write(report_path, html)
}

pub fn evaluate_case(
  case_: Case,
  validator: Validator,
  model: llm.Model,
) -> Result(#(String, Evaluation), String) {
  let system = tour.gleam_tour_md <> "\n\n" <> constants.context

  let assert Ok(program) = llm.prompt(model, system:, user: case_.contents)

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
    id: "hello",
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
    id: "defer",
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

fn make_case_3() -> Case {
  Case(
    id: "matrix",
    title: "Matrix",
    contents: "
Write a Gleam program that defines a function transpose(matrix: List(List(Int))) -> List(List(Int)) which takes a matrix of integers and returns its transpose.
The transpose flips rows into columns, so the element at position (i, j) becomes (j, i).
Include a main function that exclusively prints the transpose of [[1, 2, 3], [4, 5, 6]], nothing else.
",
    deps: [],
  )
}

fn validator_3(stdout: String) -> Bool {
  stdout
  |> string.lowercase()
  |> string.trim()
  == "[[1, 4], [2, 5], [3, 6]]"
}

pub fn generate_html(cases_and_reports: List(#(Case, List(Report)))) {
  let cases = list.map(cases_and_reports, fn(c_r) { c_r.0 })

  html.html([attribute.lang("en")], [
    html.head([], [
      html.meta([attribute.charset("utf-8")]),
      html.meta([
        attribute.name("viewport"),
        attribute.content("width=device-width, initial-scale=1"),
      ]),
      html.title([], "Gleam LLM Report"),
      html.link([
        attribute.href("https://fav.farm/%F0%9F%A4%96"),
        attribute.rel("icon"),
      ]),
      html.style([], constants.css_reset),
      html.style([], style),

      html.style(
        [],
        cases
          |> list.map(fn(case_) { "
          #case-select:has(#case-" <> case_.id <> ":checked) #view-" <> case_.id <> " { display:block; }
          #case-select:has(#case-" <> case_.id <> ":checked) .sidebar label[for=\"case-" <> case_.id <> "\"] {
            background:#e9f3ff; border:1px solid #bcd7ff; font-weight:600;
          }
        " })
          |> string.join("\n"),
      ),

      html.link([
        attribute.href(
          "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release@11.11.1/build/styles/atom-one-light.min.css",
        ),
        attribute.rel("stylesheet"),
      ]),
      html.script([attribute.src("./js/highlight.min.js")], ""),
      html.script([attribute.src("./js/highlight-gleam.js")], ""),
      html.script(
        [],
        "
          window.addEventListener(\"DOMContentLoaded\", () => {
            if (window.hljsDefineGleam) {
              hljs.registerLanguage(\"gleam\", window.hljsDefineGleam);
            }
            document.querySelectorAll(\"pre code\").forEach((el) => {
              el.classList.add(\"language-gleam\");
            });
            hljs.configure({ languages: [\"gleam\"] });
            hljs.highlightAll();
          });
",
      ),
    ]),
    html.body([], [
      html.div([attribute.id("case-select")], [
        html.div([attribute.class("app")], [
          html.aside([attribute.class("sidebar")], [
            html.h2([], [html.text("Cases")]),
            ..{
              use case_ <- list.map(cases)
              html.label(
                [
                  attribute.for("case-" <> case_.id),
                  attribute.class("case-link"),
                ],
                [html.text(case_.title)],
              )
            }
          ]),
          html.main([attribute.class("main")], {
            use #(case_, reports) <- list.map(cases_and_reports)
            html.section(
              [attribute.class("case"), attribute.id("view-" <> case_.id)],
              [
                html.h1(
                  [
                    attribute.style("font-size", "18px"),
                    attribute.style("margin", "0 0 15px"),
                  ],
                  [html.text("Case: " <> case_.title)],
                ),
                html.p([attribute.style("margin", "0 0 15px")], [
                  html.text(case_.contents),
                ]),
                html.table([], [
                  html.thead([], [
                    html.tr([], [
                      html.th([attribute.style("width", "40%")], [
                        html.text("model"),
                      ]),
                      html.th([attribute.style("width", "10%")], [
                        html.text("valid"),
                      ]),
                      html.th([], [html.text("code")]),
                    ]),
                  ]),
                  html.tbody([], {
                    use report <- list.map(reports)
                    let model = llm.model_to_identifier(report.model)

                    html.tr([], [
                      html.td([], [
                        html.text(model),
                      ]),
                      {
                        case report.eval {
                          CompileError ->
                            html.td([attribute.class("valid-false")], [
                              html.text("false"),
                            ])
                          Invalid ->
                            html.td([attribute.class("valid-false")], [
                              html.text("false"),
                            ])
                          Valid ->
                            html.td([attribute.class("valid-true")], [
                              html.text("true"),
                            ])
                        }
                      },
                      html.td([], [
                        html.a(
                          [
                            attribute.href("#code-" <> case_.id <> "-" <> model),
                            attribute.class("btn"),
                          ],
                          [html.text("View code")],
                        ),
                      ]),
                    ])
                  }),
                ]),
              ],
            )
          }),
          html.div(
            [],
            list.flatten({
              use #(case_, reports) <- list.map(cases_and_reports)
              use report <- list.map(reports)

              let model = llm.model_to_identifier(report.model)

              html.div(
                [
                  attribute.role("dialog"),
                  attribute.attribute("aria-modal", "true"),
                  attribute.class("modal"),
                  attribute.id("code-" <> case_.id <> "-" <> model),
                ],
                [
                  html.div([attribute.class("box")], [
                    html.header([], [
                      html.h3([], [
                        html.text(case_.title <> " — " <> model),
                      ]),
                      html.a([attribute.href("#"), attribute.class("close")], [
                        html.text("Close"),
                      ]),
                    ]),
                    html.div([attribute.class("body")], [
                      html.pre([], [
                        html.code([], [html.text(report.program)]),
                      ]),
                    ]),
                  ]),
                ],
              )
            }),
          ),
        ]),
        ..{
          use case_ <- list.map(cases)
          html.input([
            attribute.checked(True),
            attribute.id("case-" <> case_.id),
            attribute.name("case"),
            attribute.type_("radio"),
          ])
        }
      ]),
    ]),
  ])
  |> element.to_document_string()
}

const style = "
html,
body {
  font-family:
    system-ui,
    -apple-system,
    Segoe UI,
    Roboto,
    Arial,
    sans-serif;
}
.app {
  display: grid;
  grid-template-columns: 220px 1fr;
  min-height: 100vh;
}
/* Sidebar */
.sidebar {
  border-right: 1px solid #ddd;
  padding: 12px;
}
.sidebar h2 {
  font-size: 14px;
  margin: 0 0 8px;
}
.sidebar .case-link {
  display: block;
  padding: 6px 8px;
  border-radius: 6px;
  text-decoration: none;
  color: #000;
  border: 1px solid transparent;
  cursor: pointer;
}
.sidebar .case-link:hover {
  background: #f3f3f3;
}
/* Main */
.main {
  padding: 16px;
}
.case {
  display: none;
}
/* Radios (hide) */
input[name=\"case\"] {
  position: absolute;
  left: -9999px;
}

/* Table */
table {
  width: 100%;
  border-collapse: collapse;
}
th,
td {
  border: 1px solid #ddd;
  padding: 8px;
  text-align: left;
  vertical-align: top;
}
th {
  background: #fafafa;
}
.valid-true {
  color: #0a6e0a;
  font-weight: 600;
}
.valid-false {
  color: #b00000;
  font-weight: 600;
}
.btn {
  display: inline-block;
  padding: 4px 8px;
  border: 1px solid #888;
  border-radius: 4px;
  text-decoration: none;
  color: #000;
  background: #f7f7f7;
}
.btn:hover {
  background: #eee;
}
/* Modal via :target */
.modal {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  display: none;
  align-items: center;
  justify-content: center;
  padding: 16px;
}
.modal:target {
  display: flex;
}
.modal .box {
  background: #fff;
  max-width: 900px;
  width: 100%;
  max-height: 85vh;
  border: 1px solid #ccc;
  border-radius: 8px;
  overflow: auto;
}
.modal header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px 12px;
  border-bottom: 1px solid #eee;
}
.modal header h3 {
  font-size: 15px;
  margin: 0;
}
.modal .body {
  padding: 12px;
}
.modal .close {
  text-decoration: none;
  padding: 4px 8px;
  border: 1px solid #888;
  border-radius: 4px;
  color: #000;
  background: #f7f7f7;
}
pre {
  margin: 0;
  white-space: pre;
  overflow: auto;
}
"
