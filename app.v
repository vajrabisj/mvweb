module main

import vweb
import os
import os.cmdline {option}
import hanabi1224.biginteger

// const (
	// port = 8082
// )

struct App {
	vweb.Context
mut:
	state shared State
}

struct State {
mut:
	cnt int
}

fn main() {
	port := option(os.args,'--port','').int()
	println('vweb prime')
	vweb.run(&App{}, port)
}

fn prime_or_not(p string) ?bool {
	mut n := biginteger.from_str(p)?
	mut i := biginteger.from_int(0)
	mut flag := 0
	z := biginteger.zero
	o := biginteger.one
	t := biginteger.two
	if n == z || n == o || n == t {
		flag = 1
	}
	for i = t; i <= n / t; i=i+o {
		if n % i == z {
			flag = 1
			break
		}
	}
	if flag == 0 {
		return true
	} else { // 3
		return false
	}
}

['/prime/check']
pub fn (mut app App) checkprime() vweb.Result {
	p := app.Context.query['q']
	if ret := prime_or_not(p){
		if ret {
			return app.text('$ret: $p is a prime number')
		}else{
			return app.text('$ret: $p is not a prime number')
		}
	}else{
		println(err)
	}
}

pub fn (mut app App) index() vweb.Result {
	hello := 'pls query /prime/check to check whether number queried is prime'
	return $vweb.html()
}

