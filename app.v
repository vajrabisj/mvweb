import hanabi1224.biginteger
import vweb
import os
import os.cmdline {option}
import rand
import net.http
import x.json2
import arrays
import log


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

//__global jstr []string

pub fn (mut app App) getcoord(ll string) ?string {
	mut jl := log.Log{}
	jl.set_level(.info)
	mut jstr := []string{}
	mut confg := http.FetchConfig{}
	mut hmap := map[string]string{}
	hmap["X-Rapidapi-Key"]="05ff24eee3msh693cfdb71cc3454p16dffcjsndbf91dab6546"
	hmap["X-Rapidapi-Host"]="google-maps-geocoding.p.rapidapi.com"
	confg.header.add_custom_map(hmap) or {panic(err)}
	confg.url = "https://google-maps-geocoding.p.rapidapi.com/geocode/json?address=$ll&language=en"
	res := http.fetch(confg)?
	coord := json2.raw_decode(res.body)?
	results := coord.as_map()
	dresults := results['results'].as_map()
	for _,v in dresults{
		for i,e in v.arr(){
			if i==2 {
				inner := e.as_map()
				for kk,vv in inner{
					if kk=='location'{
						for ii,ee in vv.arr(){
							jstr << ee.str()
							jl.info(jstr.str())
						}
					}
				}
			}
		}
	}
	jl.info('jstr is: $jstr')
	arrays.rotate_left(mut jstr,1)
	jl.info('jstr after rotate is: $jstr')
	jstr << ll
	jl.info('jstr after append is: $jstr')
	jl.info('jstr convert to str is: $jstr.str()')
	return '${jstr[0]},${jstr[1]},${jstr[2]}'
}

type Jstr = []string
type Jstrm = map[string]Jstr

['/coord/check'; get]
pub fn (mut app App) checkcoord() ?vweb.Result{
	mut jl := log.Log{}
	jl.set_level(.info)
	mut jstr := []string{}
	mut jstrm := map[string]Jstr{}
	mut jstrl := []Jstrm{}
	ll := app.query['q']
	jl.info('location queried is: $ll')
	if os.exists('${@VMODROOT}/coords.txt'){
		jl.info('file existed')
		jstr = os.read_lines('${@VMODROOT}/coords.txt') or {panic(err)}
		jl.info('file contents:\n')
		for e in jstr{
			jl.info('element in jstr is: $e')
			if e.split(',')[2]==ll {
				jl.info('$ll found')
				jl.info('after split elements are: ${e.split(',')}')
				return app.text(e)
			}
		}
		if ret := app.getcoord(ll){
			jl.info('not found, so coords returned is: $ret')
			if mut oaf := os.open_append('${@VMODROOT}/coords.txt'){
				jl.info('open file to append')
				oaf.writeln(ret) or {panic(err)}
				jl.info('write $ret to file')
			}else{
				panic(err)
			}
			return app.text(ret)
		}else{
			panic(err)
		}
	}else{
		jl.info('file not existed')
		if ret := app.getcoord(ll){
			jl.info('returned is: $ret')
			if mut jf := os.create('${@VMODROOT}/coords.txt'){
				jf.writeln(ret) or {panic(err)}
			}else{
				panic(err)
			}
			return app.text(ret)
		}else{
			panic(err)
		}
	}
}

struct Gua{
		gname string
		gxiang rune
}

['/gua/grand'; get]
fn (mut app App) grand() ?vweb.Result{
	mut g := Gua{}
	ret := g.cheng_gua()
	if rn := rand.intn(64){
		rnstr := 'random number $rn generated.'
		gstr := '第${rn+1}卦：${ret[rn].gxiang} -> ${ret[rn].gname}'
		return $vweb.html()
	}else{
		panic(err)
	}
}

['/gua/list'; get]
fn (mut app App) glist() vweb.Result{
	mut g := Gua{}
	ret := g.cheng_gua()
	return $vweb.html()
}

fn (mut gua Gua) cheng_gua() map[int]Gua{
	mut guax := []rune{}
	for u in `\u4dc0` .. `\u4dff`{
		guax << u
	}
	guax << `\u4dff`
	println('length of guax is ${guax.len}')
	guam := ['乾为天','坤为地','水雷屯','山水蒙','水天需','天水讼','地水师','水地比','风天小畜','天泽履','地天泰','天地否','天火同人','火天大有','地山谦','雷地豫','泽雷随','山风蛊','地泽临','风地观','火雷噬嗑','山火贲','山地剥','地雷复','天雷无妄','山天大畜','山雷颐','泽风大过','坎为水','离为火','泽山咸','雷风恒','天山遁','雷天大壮','火地晋','地火明夷','风火家人','火泽睽','水山蹇','雷水解','山泽损','风雷益','泽天夬','天风姤','泽地萃','地风升','泽水困','水风井','泽火革','火风鼎','震为雷','艮为山','风山渐','雷泽归妹','雷火丰','火山旅','巽为风','兑为泽','风水涣','水泽节','风泽中孚','雷山小过','水火既济','火水未济']
	println('length of guam is ${guam.len}')
	mut guamp := map[int]Gua{}
	mut i := 0
	for i=0;i<=63;i++{
		guamp[i]=Gua{guam[i],guax[i]}
		//println('第${i+1}卦：${guamp[i+1].gxiang} -> ${guamp[i+1].gname}')
	}
	return guamp
}

/*
			for k, v in results{
				match k{
					'geometry'{
						llr << v
					}
					else{
						continue
					}
				}
			}
		}
	} else {println('$err')}*/