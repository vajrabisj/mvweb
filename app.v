
import vweb
import os
import os.cmdline {option}
import hanabi1224.biginteger
import rand

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

[live]
fn main() {
	port := option(os.args,'--port','').int()
	println('vweb prime')
	vweb.run(&App{}, port)
}

fn sprime_or_not(p string) ?bool {
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

fn iprime_or_not(n int) bool {
	mut i := 0
	mut flag := 0
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

['/prime/check'; get]
pub fn (mut app App) gcheckprime() vweb.Result {
	p := app.query['q']
	if ret := sprime_or_not(p){
		if ret {
			return app.text('$ret: $p is a prime number')
		}else{
			return app.text('$ret: $p is not a prime number')
		}
	}else{
		println(err)
	}
}

['/prime/check'; post]
pub fn (mut app App) pcheckprime() vweb.Result {
	p := app.form['primen']
	if ret := sprime_or_not(p){
		if ret {
			return app.text('$ret: $p is a prime number')
		}else{
			return app.text('$ret: $p is not a prime number')
		}
	}else{
		println(err)
	}
}

['/prime/list'; get]
pub fn (mut app App) glistprime() vweb.Result{
	p := app.query['q'].int()
	mut pl := []int{}
	for i in 3 .. p{
		if iprime_or_not(i){
			pl << i
		}
	}
	return app.text('prime list is: $pl')
}

['/prime/list'; post]
pub fn (mut app App) plistprime() vweb.Result{
	p := app.form['primel'].int()
	mut pl := []int{}
	for i in 3 .. p{
		if iprime_or_not(i){
			pl << i
		}
	}
	return app.text('prime list is: $pl')
}

['/rand/gen']
pub fn (mut app App) genrand() vweb.Result{
	rndg := typeof(rand.get_current_rng()).name
	rndn := rand.int31()
	rndstr := 'using $rndg generated: $rndn'
	rndl := '/prime/check?q=' + rndn.str()
	return $vweb.html()
}

pub fn (mut app App) index() vweb.Result {
	primecheck := 'Get /prime/check?q=[number to check] to check whether number queried is prime'
	primelist := 'Get /prime/list?q=[range] to list prime numbers within range'
	return $vweb.html()
}

