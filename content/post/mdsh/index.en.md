+++
title = "mdsh: Run Shell Scripts in Markdown Templates"
date = 2025-07-25T16:23:21+10:00
categories = ["project"]
tags = []
draft = false
showToc = true
summary = ""
+++

I have been using [hledger](https://hledger.org/) as my primary personal accounting software for years.
I love that I can manage my ledger in plaintext and even use Git to version control and backup.

But when it comes to generating reports, it often takes me time to figure out all the commands I need.
Also, having a way to archive previous data is important.
I used to write a shell script with all the report commands, and add a lot of `echo` statements to generate a markdown report.
However, this approach is hard to read and makes the template difficult to maintain.

That's why I made [**mdsh**](https://github.com/lancatlin/mdsh), a markdown template engine written in Go, which allows you to **execute shell scripts within Markdown**.
It allows you to use Go's template syntax in markdown, and puts the execution results in the generated output.

You can download it from the [release page](https://github.com/lancatlin/mdsh/releases).
Once you downloaded ant decompressed it, you can put the `mdsh` binary to some place in your `$PATH`. On Linux, for example, you can put it under `/usr/loca/bin` via:

    sudo cp mdsh /usr/local/bin

You can also install it with Go CLI:

    go install github.com/lancatlin/mdsh@latest

This will put it into `$GOPATH/bin` (usually `$HOME/go/bin`)

## The First Template

Suppose we want to generate a system information report.
You can define a markdown template `system-info.md` as follows:

~~~~markdown
# 💥 System Information Report for {{ sh "hostname" }}

* **Hostname**: {{ sh "hostname" }}
* **Username**: {{ sh "whoami" }}
* **Uptime**: {{ sh "uptime -p" }}
* **System**: {{ sh "uname -a" }}
* **CPU**: {{ sh "uname -m" }} — {{ sh "nproc" }} cores
* **IP Address**: {{ sh "hostname -I || ip a | grep inet" }}
* **Default Gateway**: {{ sh "ip route | grep default || netstat -rn | grep default" }}
~~~~

Run the template:

    mdsh system-info.md

It will render into:

~~~~markdown
# 💥 System Information Report for `fedora`

* **Hostname**: `fedora`
* **Username**: `wancat`
* **Uptime**: `up 1 hour, 13 minutes`
* **System**: `Linux fedora 6.15.6-200.fc42.x86_64 #1 SMP PREEMPT_DYNAMIC Thu Jul 10 15:22:32 UTC 2025 x86_64 GNU/Linux`
* **CPU**: `x86_64` — `16` cores
* **IP Address**: `172.26.198.115 2405:dc00:ec83:ec80:af9c:87ed:9bae:bd0d`
* **Default Gateway**: `default via 172.26.198.50 dev wlp1s0 proto dhcp src 172.26.198.115 metric 600`
~~~~

It makes generating reports as easy as a breeze.

## Different Template Functions

Currently, it supports 3 types of template functions, which change the format they generate to:

1. `sh`: puts the output in `inline code`
2. `shell`: puts the output in a
```
code block
```
3. `raw`: puts output without any decorations

Also, any functions and syntax supported in [text/template](https://pkg.go.dev/text/template) are supported.

## Custom Parameters from Command Line Arguments

The best part of mdsh is that it supports **custom parameters**, which means you can define the parameters you're going to use in the template, and pass them through command line arguments.

You can access the parameters through both template data and environment variables.
So you can access these variables from the script with ease.

For example, I need to generate a monthly report for my ledger.
I need to specify `begin` and `end` times for the report.

Define the template as follows:

~~~~markdown
---
params:
  b:
    required: true
  e:
    required: true
  f:
    default: examples/ledger.j
---
// The template body
~~~~

As you can see in the code, you can define custom parameters in the `params:` section in the frontmatter.
I defined 3 parameters: `b`, `e`, and `f`, which stand for begin, end, and file. (This follows the convention in hledger)

Then I can use those parameters in the template body.

~~~~markdown
# Finance Report from {{.b}} to {{.e}}

## Net Income:

{{ shell "hledger -f $f income -b $b -e $e --monthly" }}
~~~~

I use `{{ .b }}` to access the parameter directly and put it in the heading.
Then I can use `$b` in the command.
All the parameters will be passed as environment variables to the executing shell.
So you can access them very easily.

    mdsh hledger_monthly.md -b 2011-01 -e 2011-02

~~~~markdown
# Finance Report from 2011-01 to 2011-02

## Net Income:

```
Income Statement 2011-01

                         ||        Jan
=========================++============
 Revenues                ||
-------------------------++------------
 Income:Salary           ||  $2,000.00
-------------------------++------------
                         ||  $2,000.00
=========================++============
 Expenses                ||
-------------------------++------------
 Expenses:Auto           ||  $5,500.00
 Expenses:Books          ||     $20.00
 Expenses:Food:Groceries ||    $109.00
-------------------------++------------
                         ||  $5,629.00
=========================++============
 Net:                    || $-3,629.00`
```
~~~~

It can even generate usage for each template based on the frontmatter.

~~~~yaml
params:
  b:
    required: true
    usage: |
      Required.
      The begin time of report.
      Examples:
        2025-07-01
        Jul
  f:
    usage: The ledger file to parse
    default: ~/.hledger.journal
~~~~

Run the help command:

```
$ mdsh hledger_monthly.md -h
Usage of params:
  -b string
    	Required.
    	The begin time of report.
    	Examples:
    	  2025
    	  Jul
    	 (default "2011-01")
  -e string
    	Required.
    	The end time of report.
    	Same format as -b
    	 (default "2011-02")
  -f string
    	The ledger file to parse (default "examples/ledger.j")
```

## Output Filename Template

The default setting is writing the output to stdout.
If you want to save it in a file.
You can do so by specifying `output:` in frontmatter.

```yaml
output: monthly_report_{{.b}}.md
```

When running `mdsh hledger_monthly.md -b 2025-07 -e 2025-08`, it saves the output to `monthly_report_2025-07.md`.
It helps you remain the naming consistency with ease.

Not only parameters, you can also put shell script into it.
For example:

```yaml
output: sys-report-{{ raw "date --iso-8601" }}.md
```

Then it will write the result to `sys-report-2025-07-25.md`.

## Use Case Ideas

mdsh has great potential in areas that require lots of shell scripting and documentation, like sysadmin, devops, and security.
It's also good for creating documentation and tutorials, reducing the hassle of pasting command outputs over and over.

You can make it fit into your workflow by defining your own templates, with usage notes inside.
Thanks to the rich features of Go's template engine, it allows huge extensibility.
You can apply condition checks (`{{ if }}`, `{{ with }}`) or even loops.

Some potential usages are:
1. **Sysadmin/DevOps**: system snapshots, cluster health
2. **Documentation**: release notes, test results
3. **Education**: lab reports, tutorials
4. **Security/Compliance**: audits, vulnerability scans
5. **Personal Finance**: hledger, budget reports (what I'm using it for)

And many more waiting for you to discover!

---

If you found this project useful, please give me a star on [GitHub](https://github.com/lancatlin/mdsh) 🌟

---

*Side note: I developed the first version of mdsh within 2 hours at midnight while trying out [Zed](https://zed.dev/), and was impressed by its performance. I didn't use much AI for this project—sometimes you just need time and space to enjoy programming.*
