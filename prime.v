module main

import vweb

const (
	port = 8082
)

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
	println('vweb prime')
	vweb.run(&App{}, port)
}

fn prime_or_not(n int) bool {
	mut i := 0
	mut flag := 0
	if n == 0 || n == 1 || n ==2 {
		flag = 1
	}
	for i = 2; i <= n / 2; i++ {
		if n % i == 0 {
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
	p := app.Context.query['q'].int()
	if prime_or_not(p){
		return app.text('$p is a prime number')
	}else{
		return app.text('$p is not a prime number')
	}
}

pub fn (mut app App) index() vweb.Result {
	hello := 'pls query /prime/check to check whether number queried is prime'
	return $vweb.html()
}

