(function(scope){
'use strict';

function F(arity, fun, wrapper) {
  wrapper.a = arity;
  wrapper.f = fun;
  return wrapper;
}

function F2(fun) {
  return F(2, fun, function(a) { return function(b) { return fun(a,b); }; })
}
function F3(fun) {
  return F(3, fun, function(a) {
    return function(b) { return function(c) { return fun(a, b, c); }; };
  });
}
function F4(fun) {
  return F(4, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return fun(a, b, c, d); }; }; };
  });
}
function F5(fun) {
  return F(5, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return fun(a, b, c, d, e); }; }; }; };
  });
}
function F6(fun) {
  return F(6, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return fun(a, b, c, d, e, f); }; }; }; }; };
  });
}
function F7(fun) {
  return F(7, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return fun(a, b, c, d, e, f, g); }; }; }; }; }; };
  });
}
function F8(fun) {
  return F(8, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) {
    return fun(a, b, c, d, e, f, g, h); }; }; }; }; }; }; };
  });
}
function F9(fun) {
  return F(9, fun, function(a) { return function(b) { return function(c) {
    return function(d) { return function(e) { return function(f) {
    return function(g) { return function(h) { return function(i) {
    return fun(a, b, c, d, e, f, g, h, i); }; }; }; }; }; }; }; };
  });
}

function A2(fun, a, b) {
  return fun.a === 2 ? fun.f(a, b) : fun(a)(b);
}
function A3(fun, a, b, c) {
  return fun.a === 3 ? fun.f(a, b, c) : fun(a)(b)(c);
}
function A4(fun, a, b, c, d) {
  return fun.a === 4 ? fun.f(a, b, c, d) : fun(a)(b)(c)(d);
}
function A5(fun, a, b, c, d, e) {
  return fun.a === 5 ? fun.f(a, b, c, d, e) : fun(a)(b)(c)(d)(e);
}
function A6(fun, a, b, c, d, e, f) {
  return fun.a === 6 ? fun.f(a, b, c, d, e, f) : fun(a)(b)(c)(d)(e)(f);
}
function A7(fun, a, b, c, d, e, f, g) {
  return fun.a === 7 ? fun.f(a, b, c, d, e, f, g) : fun(a)(b)(c)(d)(e)(f)(g);
}
function A8(fun, a, b, c, d, e, f, g, h) {
  return fun.a === 8 ? fun.f(a, b, c, d, e, f, g, h) : fun(a)(b)(c)(d)(e)(f)(g)(h);
}
function A9(fun, a, b, c, d, e, f, g, h, i) {
  return fun.a === 9 ? fun.f(a, b, c, d, e, f, g, h, i) : fun(a)(b)(c)(d)(e)(f)(g)(h)(i);
}




// EQUALITY

function _Utils_eq(x, y)
{
	for (
		var pair, stack = [], isEqual = _Utils_eqHelp(x, y, 0, stack);
		isEqual && (pair = stack.pop());
		isEqual = _Utils_eqHelp(pair.a, pair.b, 0, stack)
		)
	{}

	return isEqual;
}

function _Utils_eqHelp(x, y, depth, stack)
{
	if (x === y)
	{
		return true;
	}

	if (typeof x !== 'object' || x === null || y === null)
	{
		typeof x === 'function' && _Debug_crash(5);
		return false;
	}

	if (depth > 100)
	{
		stack.push(_Utils_Tuple2(x,y));
		return true;
	}

	/**_UNUSED/
	if (x.$ === 'Set_elm_builtin')
	{
		x = $elm$core$Set$toList(x);
		y = $elm$core$Set$toList(y);
	}
	if (x.$ === 'RBNode_elm_builtin' || x.$ === 'RBEmpty_elm_builtin')
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	/**/
	if (x.$ < 0)
	{
		x = $elm$core$Dict$toList(x);
		y = $elm$core$Dict$toList(y);
	}
	//*/

	for (var key in x)
	{
		if (!_Utils_eqHelp(x[key], y[key], depth + 1, stack))
		{
			return false;
		}
	}
	return true;
}

var _Utils_equal = F2(_Utils_eq);
var _Utils_notEqual = F2(function(a, b) { return !_Utils_eq(a,b); });



// COMPARISONS

// Code in Generate/JavaScript.hs, Basics.js, and List.js depends on
// the particular integer values assigned to LT, EQ, and GT.

function _Utils_cmp(x, y, ord)
{
	if (typeof x !== 'object')
	{
		return x === y ? /*EQ*/ 0 : x < y ? /*LT*/ -1 : /*GT*/ 1;
	}

	/**_UNUSED/
	if (x instanceof String)
	{
		var a = x.valueOf();
		var b = y.valueOf();
		return a === b ? 0 : a < b ? -1 : 1;
	}
	//*/

	/**/
	if (typeof x.$ === 'undefined')
	//*/
	/**_UNUSED/
	if (x.$[0] === '#')
	//*/
	{
		return (ord = _Utils_cmp(x.a, y.a))
			? ord
			: (ord = _Utils_cmp(x.b, y.b))
				? ord
				: _Utils_cmp(x.c, y.c);
	}

	// traverse conses until end of a list or a mismatch
	for (; x.b && y.b && !(ord = _Utils_cmp(x.a, y.a)); x = x.b, y = y.b) {} // WHILE_CONSES
	return ord || (x.b ? /*GT*/ 1 : y.b ? /*LT*/ -1 : /*EQ*/ 0);
}

var _Utils_lt = F2(function(a, b) { return _Utils_cmp(a, b) < 0; });
var _Utils_le = F2(function(a, b) { return _Utils_cmp(a, b) < 1; });
var _Utils_gt = F2(function(a, b) { return _Utils_cmp(a, b) > 0; });
var _Utils_ge = F2(function(a, b) { return _Utils_cmp(a, b) >= 0; });

var _Utils_compare = F2(function(x, y)
{
	var n = _Utils_cmp(x, y);
	return n < 0 ? $elm$core$Basics$LT : n ? $elm$core$Basics$GT : $elm$core$Basics$EQ;
});


// COMMON VALUES

var _Utils_Tuple0 = 0;
var _Utils_Tuple0_UNUSED = { $: '#0' };

function _Utils_Tuple2(a, b) { return { a: a, b: b }; }
function _Utils_Tuple2_UNUSED(a, b) { return { $: '#2', a: a, b: b }; }

function _Utils_Tuple3(a, b, c) { return { a: a, b: b, c: c }; }
function _Utils_Tuple3_UNUSED(a, b, c) { return { $: '#3', a: a, b: b, c: c }; }

function _Utils_chr(c) { return c; }
function _Utils_chr_UNUSED(c) { return new String(c); }


// RECORDS

function _Utils_update(oldRecord, updatedFields)
{
	var newRecord = {};

	for (var key in oldRecord)
	{
		newRecord[key] = oldRecord[key];
	}

	for (var key in updatedFields)
	{
		newRecord[key] = updatedFields[key];
	}

	return newRecord;
}


// APPEND

var _Utils_append = F2(_Utils_ap);

function _Utils_ap(xs, ys)
{
	// append Strings
	if (typeof xs === 'string')
	{
		return xs + ys;
	}

	// append Lists
	if (!xs.b)
	{
		return ys;
	}
	var root = _List_Cons(xs.a, ys);
	xs = xs.b
	for (var curr = root; xs.b; xs = xs.b) // WHILE_CONS
	{
		curr = curr.b = _List_Cons(xs.a, ys);
	}
	return root;
}



var _List_Nil = { $: 0 };
var _List_Nil_UNUSED = { $: '[]' };

function _List_Cons(hd, tl) { return { $: 1, a: hd, b: tl }; }
function _List_Cons_UNUSED(hd, tl) { return { $: '::', a: hd, b: tl }; }


var _List_cons = F2(_List_Cons);

function _List_fromArray(arr)
{
	var out = _List_Nil;
	for (var i = arr.length; i--; )
	{
		out = _List_Cons(arr[i], out);
	}
	return out;
}

function _List_toArray(xs)
{
	for (var out = []; xs.b; xs = xs.b) // WHILE_CONS
	{
		out.push(xs.a);
	}
	return out;
}

var _List_map2 = F3(function(f, xs, ys)
{
	for (var arr = []; xs.b && ys.b; xs = xs.b, ys = ys.b) // WHILE_CONSES
	{
		arr.push(A2(f, xs.a, ys.a));
	}
	return _List_fromArray(arr);
});

var _List_map3 = F4(function(f, xs, ys, zs)
{
	for (var arr = []; xs.b && ys.b && zs.b; xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A3(f, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map4 = F5(function(f, ws, xs, ys, zs)
{
	for (var arr = []; ws.b && xs.b && ys.b && zs.b; ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A4(f, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_map5 = F6(function(f, vs, ws, xs, ys, zs)
{
	for (var arr = []; vs.b && ws.b && xs.b && ys.b && zs.b; vs = vs.b, ws = ws.b, xs = xs.b, ys = ys.b, zs = zs.b) // WHILE_CONSES
	{
		arr.push(A5(f, vs.a, ws.a, xs.a, ys.a, zs.a));
	}
	return _List_fromArray(arr);
});

var _List_sortBy = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		return _Utils_cmp(f(a), f(b));
	}));
});

var _List_sortWith = F2(function(f, xs)
{
	return _List_fromArray(_List_toArray(xs).sort(function(a, b) {
		var ord = A2(f, a, b);
		return ord === $elm$core$Basics$EQ ? 0 : ord === $elm$core$Basics$LT ? -1 : 1;
	}));
});



var _JsArray_empty = [];

function _JsArray_singleton(value)
{
    return [value];
}

function _JsArray_length(array)
{
    return array.length;
}

var _JsArray_initialize = F3(function(size, offset, func)
{
    var result = new Array(size);

    for (var i = 0; i < size; i++)
    {
        result[i] = func(offset + i);
    }

    return result;
});

var _JsArray_initializeFromList = F2(function (max, ls)
{
    var result = new Array(max);

    for (var i = 0; i < max && ls.b; i++)
    {
        result[i] = ls.a;
        ls = ls.b;
    }

    result.length = i;
    return _Utils_Tuple2(result, ls);
});

var _JsArray_unsafeGet = F2(function(index, array)
{
    return array[index];
});

var _JsArray_unsafeSet = F3(function(index, value, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[index] = value;
    return result;
});

var _JsArray_push = F2(function(value, array)
{
    var length = array.length;
    var result = new Array(length + 1);

    for (var i = 0; i < length; i++)
    {
        result[i] = array[i];
    }

    result[length] = value;
    return result;
});

var _JsArray_foldl = F3(function(func, acc, array)
{
    var length = array.length;

    for (var i = 0; i < length; i++)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_foldr = F3(function(func, acc, array)
{
    for (var i = array.length - 1; i >= 0; i--)
    {
        acc = A2(func, array[i], acc);
    }

    return acc;
});

var _JsArray_map = F2(function(func, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = func(array[i]);
    }

    return result;
});

var _JsArray_indexedMap = F3(function(func, offset, array)
{
    var length = array.length;
    var result = new Array(length);

    for (var i = 0; i < length; i++)
    {
        result[i] = A2(func, offset + i, array[i]);
    }

    return result;
});

var _JsArray_slice = F3(function(from, to, array)
{
    return array.slice(from, to);
});

var _JsArray_appendN = F3(function(n, dest, source)
{
    var destLen = dest.length;
    var itemsToCopy = n - destLen;

    if (itemsToCopy > source.length)
    {
        itemsToCopy = source.length;
    }

    var size = destLen + itemsToCopy;
    var result = new Array(size);

    for (var i = 0; i < destLen; i++)
    {
        result[i] = dest[i];
    }

    for (var i = 0; i < itemsToCopy; i++)
    {
        result[i + destLen] = source[i];
    }

    return result;
});



// LOG

var _Debug_log = F2(function(tag, value)
{
	return value;
});

var _Debug_log_UNUSED = F2(function(tag, value)
{
	console.log(tag + ': ' + _Debug_toString(value));
	return value;
});


// TODOS

function _Debug_todo(moduleName, region)
{
	return function(message) {
		_Debug_crash(8, moduleName, region, message);
	};
}

function _Debug_todoCase(moduleName, region, value)
{
	return function(message) {
		_Debug_crash(9, moduleName, region, value, message);
	};
}


// TO STRING

function _Debug_toString(value)
{
	return '<internals>';
}

function _Debug_toString_UNUSED(value)
{
	return _Debug_toAnsiString(false, value);
}

function _Debug_toAnsiString(ansi, value)
{
	if (typeof value === 'function')
	{
		return _Debug_internalColor(ansi, '<function>');
	}

	if (typeof value === 'boolean')
	{
		return _Debug_ctorColor(ansi, value ? 'True' : 'False');
	}

	if (typeof value === 'number')
	{
		return _Debug_numberColor(ansi, value + '');
	}

	if (value instanceof String)
	{
		return _Debug_charColor(ansi, "'" + _Debug_addSlashes(value, true) + "'");
	}

	if (typeof value === 'string')
	{
		return _Debug_stringColor(ansi, '"' + _Debug_addSlashes(value, false) + '"');
	}

	if (typeof value === 'object' && '$' in value)
	{
		var tag = value.$;

		if (typeof tag === 'number')
		{
			return _Debug_internalColor(ansi, '<internals>');
		}

		if (tag[0] === '#')
		{
			var output = [];
			for (var k in value)
			{
				if (k === '$') continue;
				output.push(_Debug_toAnsiString(ansi, value[k]));
			}
			return '(' + output.join(',') + ')';
		}

		if (tag === 'Set_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Set')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Set$toList(value));
		}

		if (tag === 'RBNode_elm_builtin' || tag === 'RBEmpty_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Dict')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Dict$toList(value));
		}

		if (tag === 'Array_elm_builtin')
		{
			return _Debug_ctorColor(ansi, 'Array')
				+ _Debug_fadeColor(ansi, '.fromList') + ' '
				+ _Debug_toAnsiString(ansi, $elm$core$Array$toList(value));
		}

		if (tag === '::' || tag === '[]')
		{
			var output = '[';

			value.b && (output += _Debug_toAnsiString(ansi, value.a), value = value.b)

			for (; value.b; value = value.b) // WHILE_CONS
			{
				output += ',' + _Debug_toAnsiString(ansi, value.a);
			}
			return output + ']';
		}

		var output = '';
		for (var i in value)
		{
			if (i === '$') continue;
			var str = _Debug_toAnsiString(ansi, value[i]);
			var c0 = str[0];
			var parenless = c0 === '{' || c0 === '(' || c0 === '[' || c0 === '<' || c0 === '"' || str.indexOf(' ') < 0;
			output += ' ' + (parenless ? str : '(' + str + ')');
		}
		return _Debug_ctorColor(ansi, tag) + output;
	}

	if (typeof DataView === 'function' && value instanceof DataView)
	{
		return _Debug_stringColor(ansi, '<' + value.byteLength + ' bytes>');
	}

	if (typeof File !== 'undefined' && value instanceof File)
	{
		return _Debug_internalColor(ansi, '<' + value.name + '>');
	}

	if (typeof value === 'object')
	{
		var output = [];
		for (var key in value)
		{
			var field = key[0] === '_' ? key.slice(1) : key;
			output.push(_Debug_fadeColor(ansi, field) + ' = ' + _Debug_toAnsiString(ansi, value[key]));
		}
		if (output.length === 0)
		{
			return '{}';
		}
		return '{ ' + output.join(', ') + ' }';
	}

	return _Debug_internalColor(ansi, '<internals>');
}

function _Debug_addSlashes(str, isChar)
{
	var s = str
		.replace(/\\/g, '\\\\')
		.replace(/\n/g, '\\n')
		.replace(/\t/g, '\\t')
		.replace(/\r/g, '\\r')
		.replace(/\v/g, '\\v')
		.replace(/\0/g, '\\0');

	if (isChar)
	{
		return s.replace(/\'/g, '\\\'');
	}
	else
	{
		return s.replace(/\"/g, '\\"');
	}
}

function _Debug_ctorColor(ansi, string)
{
	return ansi ? '\x1b[96m' + string + '\x1b[0m' : string;
}

function _Debug_numberColor(ansi, string)
{
	return ansi ? '\x1b[95m' + string + '\x1b[0m' : string;
}

function _Debug_stringColor(ansi, string)
{
	return ansi ? '\x1b[93m' + string + '\x1b[0m' : string;
}

function _Debug_charColor(ansi, string)
{
	return ansi ? '\x1b[92m' + string + '\x1b[0m' : string;
}

function _Debug_fadeColor(ansi, string)
{
	return ansi ? '\x1b[37m' + string + '\x1b[0m' : string;
}

function _Debug_internalColor(ansi, string)
{
	return ansi ? '\x1b[36m' + string + '\x1b[0m' : string;
}

function _Debug_toHexDigit(n)
{
	return String.fromCharCode(n < 10 ? 48 + n : 55 + n);
}


// CRASH


function _Debug_crash(identifier)
{
	throw new Error('https://github.com/elm/core/blob/1.0.0/hints/' + identifier + '.md');
}


function _Debug_crash_UNUSED(identifier, fact1, fact2, fact3, fact4)
{
	switch(identifier)
	{
		case 0:
			throw new Error('What node should I take over? In JavaScript I need something like:\n\n    Elm.Main.init({\n        node: document.getElementById("elm-node")\n    })\n\nYou need to do this with any Browser.sandbox or Browser.element program.');

		case 1:
			throw new Error('Browser.application programs cannot handle URLs like this:\n\n    ' + document.location.href + '\n\nWhat is the root? The root of your file system? Try looking at this program with `elm reactor` or some other server.');

		case 2:
			var jsonErrorString = fact1;
			throw new Error('Problem with the flags given to your Elm program on initialization.\n\n' + jsonErrorString);

		case 3:
			var portName = fact1;
			throw new Error('There can only be one port named `' + portName + '`, but your program has multiple.');

		case 4:
			var portName = fact1;
			var problem = fact2;
			throw new Error('Trying to send an unexpected type of value through port `' + portName + '`:\n' + problem);

		case 5:
			throw new Error('Trying to use `(==)` on functions.\nThere is no way to know if functions are "the same" in the Elm sense.\nRead more about this at https://package.elm-lang.org/packages/elm/core/latest/Basics#== which describes why it is this way and what the better version will look like.');

		case 6:
			var moduleName = fact1;
			throw new Error('Your page is loading multiple Elm scripts with a module named ' + moduleName + '. Maybe a duplicate script is getting loaded accidentally? If not, rename one of them so I know which is which!');

		case 8:
			var moduleName = fact1;
			var region = fact2;
			var message = fact3;
			throw new Error('TODO in module `' + moduleName + '` ' + _Debug_regionToString(region) + '\n\n' + message);

		case 9:
			var moduleName = fact1;
			var region = fact2;
			var value = fact3;
			var message = fact4;
			throw new Error(
				'TODO in module `' + moduleName + '` from the `case` expression '
				+ _Debug_regionToString(region) + '\n\nIt received the following value:\n\n    '
				+ _Debug_toString(value).replace('\n', '\n    ')
				+ '\n\nBut the branch that handles it says:\n\n    ' + message.replace('\n', '\n    ')
			);

		case 10:
			throw new Error('Bug in https://github.com/elm/virtual-dom/issues');

		case 11:
			throw new Error('Cannot perform mod 0. Division by zero error.');
	}
}

function _Debug_regionToString(region)
{
	if (region.bf.aM === region.bx.aM)
	{
		return 'on line ' + region.bf.aM;
	}
	return 'on lines ' + region.bf.aM + ' through ' + region.bx.aM;
}



// MATH

var _Basics_add = F2(function(a, b) { return a + b; });
var _Basics_sub = F2(function(a, b) { return a - b; });
var _Basics_mul = F2(function(a, b) { return a * b; });
var _Basics_fdiv = F2(function(a, b) { return a / b; });
var _Basics_idiv = F2(function(a, b) { return (a / b) | 0; });
var _Basics_pow = F2(Math.pow);

var _Basics_remainderBy = F2(function(b, a) { return a % b; });

// https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/divmodnote-letter.pdf
var _Basics_modBy = F2(function(modulus, x)
{
	var answer = x % modulus;
	return modulus === 0
		? _Debug_crash(11)
		:
	((answer > 0 && modulus < 0) || (answer < 0 && modulus > 0))
		? answer + modulus
		: answer;
});


// TRIGONOMETRY

var _Basics_pi = Math.PI;
var _Basics_e = Math.E;
var _Basics_cos = Math.cos;
var _Basics_sin = Math.sin;
var _Basics_tan = Math.tan;
var _Basics_acos = Math.acos;
var _Basics_asin = Math.asin;
var _Basics_atan = Math.atan;
var _Basics_atan2 = F2(Math.atan2);


// MORE MATH

function _Basics_toFloat(x) { return x; }
function _Basics_truncate(n) { return n | 0; }
function _Basics_isInfinite(n) { return n === Infinity || n === -Infinity; }

var _Basics_ceiling = Math.ceil;
var _Basics_floor = Math.floor;
var _Basics_round = Math.round;
var _Basics_sqrt = Math.sqrt;
var _Basics_log = Math.log;
var _Basics_isNaN = isNaN;


// BOOLEANS

function _Basics_not(bool) { return !bool; }
var _Basics_and = F2(function(a, b) { return a && b; });
var _Basics_or  = F2(function(a, b) { return a || b; });
var _Basics_xor = F2(function(a, b) { return a !== b; });



var _String_cons = F2(function(chr, str)
{
	return chr + str;
});

function _String_uncons(string)
{
	var word = string.charCodeAt(0);
	return !isNaN(word)
		? $elm$core$Maybe$Just(
			0xD800 <= word && word <= 0xDBFF
				? _Utils_Tuple2(_Utils_chr(string[0] + string[1]), string.slice(2))
				: _Utils_Tuple2(_Utils_chr(string[0]), string.slice(1))
		)
		: $elm$core$Maybe$Nothing;
}

var _String_append = F2(function(a, b)
{
	return a + b;
});

function _String_length(str)
{
	return str.length;
}

var _String_map = F2(function(func, string)
{
	var len = string.length;
	var array = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = string.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			array[i] = func(_Utils_chr(string[i] + string[i+1]));
			i += 2;
			continue;
		}
		array[i] = func(_Utils_chr(string[i]));
		i++;
	}
	return array.join('');
});

var _String_filter = F2(function(isGood, str)
{
	var arr = [];
	var len = str.length;
	var i = 0;
	while (i < len)
	{
		var char = str[i];
		var word = str.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += str[i];
			i++;
		}

		if (isGood(_Utils_chr(char)))
		{
			arr.push(char);
		}
	}
	return arr.join('');
});

function _String_reverse(str)
{
	var len = str.length;
	var arr = new Array(len);
	var i = 0;
	while (i < len)
	{
		var word = str.charCodeAt(i);
		if (0xD800 <= word && word <= 0xDBFF)
		{
			arr[len - i] = str[i + 1];
			i++;
			arr[len - i] = str[i - 1];
			i++;
		}
		else
		{
			arr[len - i] = str[i];
			i++;
		}
	}
	return arr.join('');
}

var _String_foldl = F3(function(func, state, string)
{
	var len = string.length;
	var i = 0;
	while (i < len)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		i++;
		if (0xD800 <= word && word <= 0xDBFF)
		{
			char += string[i];
			i++;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_foldr = F3(function(func, state, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		state = A2(func, _Utils_chr(char), state);
	}
	return state;
});

var _String_split = F2(function(sep, str)
{
	return str.split(sep);
});

var _String_join = F2(function(sep, strs)
{
	return strs.join(sep);
});

var _String_slice = F3(function(start, end, str) {
	return str.slice(start, end);
});

function _String_trim(str)
{
	return str.trim();
}

function _String_trimLeft(str)
{
	return str.replace(/^\s+/, '');
}

function _String_trimRight(str)
{
	return str.replace(/\s+$/, '');
}

function _String_words(str)
{
	return _List_fromArray(str.trim().split(/\s+/g));
}

function _String_lines(str)
{
	return _List_fromArray(str.split(/\r\n|\r|\n/g));
}

function _String_toUpper(str)
{
	return str.toUpperCase();
}

function _String_toLower(str)
{
	return str.toLowerCase();
}

var _String_any = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (isGood(_Utils_chr(char)))
		{
			return true;
		}
	}
	return false;
});

var _String_all = F2(function(isGood, string)
{
	var i = string.length;
	while (i--)
	{
		var char = string[i];
		var word = string.charCodeAt(i);
		if (0xDC00 <= word && word <= 0xDFFF)
		{
			i--;
			char = string[i] + char;
		}
		if (!isGood(_Utils_chr(char)))
		{
			return false;
		}
	}
	return true;
});

var _String_contains = F2(function(sub, str)
{
	return str.indexOf(sub) > -1;
});

var _String_startsWith = F2(function(sub, str)
{
	return str.indexOf(sub) === 0;
});

var _String_endsWith = F2(function(sub, str)
{
	return str.length >= sub.length &&
		str.lastIndexOf(sub) === str.length - sub.length;
});

var _String_indexes = F2(function(sub, str)
{
	var subLen = sub.length;

	if (subLen < 1)
	{
		return _List_Nil;
	}

	var i = 0;
	var is = [];

	while ((i = str.indexOf(sub, i)) > -1)
	{
		is.push(i);
		i = i + subLen;
	}

	return _List_fromArray(is);
});


// TO STRING

function _String_fromNumber(number)
{
	return number + '';
}


// INT CONVERSIONS

function _String_toInt(str)
{
	var total = 0;
	var code0 = str.charCodeAt(0);
	var start = code0 == 0x2B /* + */ || code0 == 0x2D /* - */ ? 1 : 0;

	for (var i = start; i < str.length; ++i)
	{
		var code = str.charCodeAt(i);
		if (code < 0x30 || 0x39 < code)
		{
			return $elm$core$Maybe$Nothing;
		}
		total = 10 * total + code - 0x30;
	}

	return i == start
		? $elm$core$Maybe$Nothing
		: $elm$core$Maybe$Just(code0 == 0x2D ? -total : total);
}


// FLOAT CONVERSIONS

function _String_toFloat(s)
{
	// check if it is a hex, octal, or binary number
	if (s.length === 0 || /[\sxbo]/.test(s))
	{
		return $elm$core$Maybe$Nothing;
	}
	var n = +s;
	// faster isNaN check
	return n === n ? $elm$core$Maybe$Just(n) : $elm$core$Maybe$Nothing;
}

function _String_fromList(chars)
{
	return _List_toArray(chars).join('');
}




function _Char_toCode(char)
{
	var code = char.charCodeAt(0);
	if (0xD800 <= code && code <= 0xDBFF)
	{
		return (code - 0xD800) * 0x400 + char.charCodeAt(1) - 0xDC00 + 0x10000
	}
	return code;
}

function _Char_fromCode(code)
{
	return _Utils_chr(
		(code < 0 || 0x10FFFF < code)
			? '\uFFFD'
			:
		(code <= 0xFFFF)
			? String.fromCharCode(code)
			:
		(code -= 0x10000,
			String.fromCharCode(Math.floor(code / 0x400) + 0xD800, code % 0x400 + 0xDC00)
		)
	);
}

function _Char_toUpper(char)
{
	return _Utils_chr(char.toUpperCase());
}

function _Char_toLower(char)
{
	return _Utils_chr(char.toLowerCase());
}

function _Char_toLocaleUpper(char)
{
	return _Utils_chr(char.toLocaleUpperCase());
}

function _Char_toLocaleLower(char)
{
	return _Utils_chr(char.toLocaleLowerCase());
}



/**_UNUSED/
function _Json_errorToString(error)
{
	return $elm$json$Json$Decode$errorToString(error);
}
//*/


// CORE DECODERS

function _Json_succeed(msg)
{
	return {
		$: 0,
		a: msg
	};
}

function _Json_fail(msg)
{
	return {
		$: 1,
		a: msg
	};
}

function _Json_decodePrim(decoder)
{
	return { $: 2, b: decoder };
}

var _Json_decodeInt = _Json_decodePrim(function(value) {
	return (typeof value !== 'number')
		? _Json_expecting('an INT', value)
		:
	(-2147483647 < value && value < 2147483647 && (value | 0) === value)
		? $elm$core$Result$Ok(value)
		:
	(isFinite(value) && !(value % 1))
		? $elm$core$Result$Ok(value)
		: _Json_expecting('an INT', value);
});

var _Json_decodeBool = _Json_decodePrim(function(value) {
	return (typeof value === 'boolean')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a BOOL', value);
});

var _Json_decodeFloat = _Json_decodePrim(function(value) {
	return (typeof value === 'number')
		? $elm$core$Result$Ok(value)
		: _Json_expecting('a FLOAT', value);
});

var _Json_decodeValue = _Json_decodePrim(function(value) {
	return $elm$core$Result$Ok(_Json_wrap(value));
});

var _Json_decodeString = _Json_decodePrim(function(value) {
	return (typeof value === 'string')
		? $elm$core$Result$Ok(value)
		: (value instanceof String)
			? $elm$core$Result$Ok(value + '')
			: _Json_expecting('a STRING', value);
});

function _Json_decodeList(decoder) { return { $: 3, b: decoder }; }
function _Json_decodeArray(decoder) { return { $: 4, b: decoder }; }

function _Json_decodeNull(value) { return { $: 5, c: value }; }

var _Json_decodeField = F2(function(field, decoder)
{
	return {
		$: 6,
		d: field,
		b: decoder
	};
});

var _Json_decodeIndex = F2(function(index, decoder)
{
	return {
		$: 7,
		e: index,
		b: decoder
	};
});

function _Json_decodeKeyValuePairs(decoder)
{
	return {
		$: 8,
		b: decoder
	};
}

function _Json_mapMany(f, decoders)
{
	return {
		$: 9,
		f: f,
		g: decoders
	};
}

var _Json_andThen = F2(function(callback, decoder)
{
	return {
		$: 10,
		b: decoder,
		h: callback
	};
});

function _Json_oneOf(decoders)
{
	return {
		$: 11,
		g: decoders
	};
}


// DECODING OBJECTS

var _Json_map1 = F2(function(f, d1)
{
	return _Json_mapMany(f, [d1]);
});

var _Json_map2 = F3(function(f, d1, d2)
{
	return _Json_mapMany(f, [d1, d2]);
});

var _Json_map3 = F4(function(f, d1, d2, d3)
{
	return _Json_mapMany(f, [d1, d2, d3]);
});

var _Json_map4 = F5(function(f, d1, d2, d3, d4)
{
	return _Json_mapMany(f, [d1, d2, d3, d4]);
});

var _Json_map5 = F6(function(f, d1, d2, d3, d4, d5)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5]);
});

var _Json_map6 = F7(function(f, d1, d2, d3, d4, d5, d6)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6]);
});

var _Json_map7 = F8(function(f, d1, d2, d3, d4, d5, d6, d7)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7]);
});

var _Json_map8 = F9(function(f, d1, d2, d3, d4, d5, d6, d7, d8)
{
	return _Json_mapMany(f, [d1, d2, d3, d4, d5, d6, d7, d8]);
});


// DECODE

var _Json_runOnString = F2(function(decoder, string)
{
	try
	{
		var value = JSON.parse(string);
		return _Json_runHelp(decoder, value);
	}
	catch (e)
	{
		return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'This is not valid JSON! ' + e.message, _Json_wrap(string)));
	}
});

var _Json_run = F2(function(decoder, value)
{
	return _Json_runHelp(decoder, _Json_unwrap(value));
});

function _Json_runHelp(decoder, value)
{
	switch (decoder.$)
	{
		case 2:
			return decoder.b(value);

		case 5:
			return (value === null)
				? $elm$core$Result$Ok(decoder.c)
				: _Json_expecting('null', value);

		case 3:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('a LIST', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _List_fromArray);

		case 4:
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			return _Json_runArrayDecoder(decoder.b, value, _Json_toElmArray);

		case 6:
			var field = decoder.d;
			if (typeof value !== 'object' || value === null || !(field in value))
			{
				return _Json_expecting('an OBJECT with a field named `' + field + '`', value);
			}
			var result = _Json_runHelp(decoder.b, value[field]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, field, result.a));

		case 7:
			var index = decoder.e;
			if (!_Json_isArray(value))
			{
				return _Json_expecting('an ARRAY', value);
			}
			if (index >= value.length)
			{
				return _Json_expecting('a LONGER array. Need index ' + index + ' but only see ' + value.length + ' entries', value);
			}
			var result = _Json_runHelp(decoder.b, value[index]);
			return ($elm$core$Result$isOk(result)) ? result : $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, index, result.a));

		case 8:
			if (typeof value !== 'object' || value === null || _Json_isArray(value))
			{
				return _Json_expecting('an OBJECT', value);
			}

			var keyValuePairs = _List_Nil;
			// TODO test perf of Object.keys and switch when support is good enough
			for (var key in value)
			{
				if (value.hasOwnProperty(key))
				{
					var result = _Json_runHelp(decoder.b, value[key]);
					if (!$elm$core$Result$isOk(result))
					{
						return $elm$core$Result$Err(A2($elm$json$Json$Decode$Field, key, result.a));
					}
					keyValuePairs = _List_Cons(_Utils_Tuple2(key, result.a), keyValuePairs);
				}
			}
			return $elm$core$Result$Ok($elm$core$List$reverse(keyValuePairs));

		case 9:
			var answer = decoder.f;
			var decoders = decoder.g;
			for (var i = 0; i < decoders.length; i++)
			{
				var result = _Json_runHelp(decoders[i], value);
				if (!$elm$core$Result$isOk(result))
				{
					return result;
				}
				answer = answer(result.a);
			}
			return $elm$core$Result$Ok(answer);

		case 10:
			var result = _Json_runHelp(decoder.b, value);
			return (!$elm$core$Result$isOk(result))
				? result
				: _Json_runHelp(decoder.h(result.a), value);

		case 11:
			var errors = _List_Nil;
			for (var temp = decoder.g; temp.b; temp = temp.b) // WHILE_CONS
			{
				var result = _Json_runHelp(temp.a, value);
				if ($elm$core$Result$isOk(result))
				{
					return result;
				}
				errors = _List_Cons(result.a, errors);
			}
			return $elm$core$Result$Err($elm$json$Json$Decode$OneOf($elm$core$List$reverse(errors)));

		case 1:
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, decoder.a, _Json_wrap(value)));

		case 0:
			return $elm$core$Result$Ok(decoder.a);
	}
}

function _Json_runArrayDecoder(decoder, value, toElmValue)
{
	var len = value.length;
	var array = new Array(len);
	for (var i = 0; i < len; i++)
	{
		var result = _Json_runHelp(decoder, value[i]);
		if (!$elm$core$Result$isOk(result))
		{
			return $elm$core$Result$Err(A2($elm$json$Json$Decode$Index, i, result.a));
		}
		array[i] = result.a;
	}
	return $elm$core$Result$Ok(toElmValue(array));
}

function _Json_isArray(value)
{
	return Array.isArray(value) || (typeof FileList !== 'undefined' && value instanceof FileList);
}

function _Json_toElmArray(array)
{
	return A2($elm$core$Array$initialize, array.length, function(i) { return array[i]; });
}

function _Json_expecting(type, value)
{
	return $elm$core$Result$Err(A2($elm$json$Json$Decode$Failure, 'Expecting ' + type, _Json_wrap(value)));
}


// EQUALITY

function _Json_equality(x, y)
{
	if (x === y)
	{
		return true;
	}

	if (x.$ !== y.$)
	{
		return false;
	}

	switch (x.$)
	{
		case 0:
		case 1:
			return x.a === y.a;

		case 2:
			return x.b === y.b;

		case 5:
			return x.c === y.c;

		case 3:
		case 4:
		case 8:
			return _Json_equality(x.b, y.b);

		case 6:
			return x.d === y.d && _Json_equality(x.b, y.b);

		case 7:
			return x.e === y.e && _Json_equality(x.b, y.b);

		case 9:
			return x.f === y.f && _Json_listEquality(x.g, y.g);

		case 10:
			return x.h === y.h && _Json_equality(x.b, y.b);

		case 11:
			return _Json_listEquality(x.g, y.g);
	}
}

function _Json_listEquality(aDecoders, bDecoders)
{
	var len = aDecoders.length;
	if (len !== bDecoders.length)
	{
		return false;
	}
	for (var i = 0; i < len; i++)
	{
		if (!_Json_equality(aDecoders[i], bDecoders[i]))
		{
			return false;
		}
	}
	return true;
}


// ENCODE

var _Json_encode = F2(function(indentLevel, value)
{
	return JSON.stringify(_Json_unwrap(value), null, indentLevel) + '';
});

function _Json_wrap_UNUSED(value) { return { $: 0, a: value }; }
function _Json_unwrap_UNUSED(value) { return value.a; }

function _Json_wrap(value) { return value; }
function _Json_unwrap(value) { return value; }

function _Json_emptyArray() { return []; }
function _Json_emptyObject() { return {}; }

var _Json_addField = F3(function(key, value, object)
{
	object[key] = _Json_unwrap(value);
	return object;
});

function _Json_addEntry(func)
{
	return F2(function(entry, array)
	{
		array.push(_Json_unwrap(func(entry)));
		return array;
	});
}

var _Json_encodeNull = _Json_wrap(null);



// TASKS

function _Scheduler_succeed(value)
{
	return {
		$: 0,
		a: value
	};
}

function _Scheduler_fail(error)
{
	return {
		$: 1,
		a: error
	};
}

function _Scheduler_binding(callback)
{
	return {
		$: 2,
		b: callback,
		c: null
	};
}

var _Scheduler_andThen = F2(function(callback, task)
{
	return {
		$: 3,
		b: callback,
		d: task
	};
});

var _Scheduler_onError = F2(function(callback, task)
{
	return {
		$: 4,
		b: callback,
		d: task
	};
});

function _Scheduler_receive(callback)
{
	return {
		$: 5,
		b: callback
	};
}


// PROCESSES

var _Scheduler_guid = 0;

function _Scheduler_rawSpawn(task)
{
	var proc = {
		$: 0,
		e: _Scheduler_guid++,
		f: task,
		g: null,
		h: []
	};

	_Scheduler_enqueue(proc);

	return proc;
}

function _Scheduler_spawn(task)
{
	return _Scheduler_binding(function(callback) {
		callback(_Scheduler_succeed(_Scheduler_rawSpawn(task)));
	});
}

function _Scheduler_rawSend(proc, msg)
{
	proc.h.push(msg);
	_Scheduler_enqueue(proc);
}

var _Scheduler_send = F2(function(proc, msg)
{
	return _Scheduler_binding(function(callback) {
		_Scheduler_rawSend(proc, msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});

function _Scheduler_kill(proc)
{
	return _Scheduler_binding(function(callback) {
		var task = proc.f;
		if (task.$ === 2 && task.c)
		{
			task.c();
		}

		proc.f = null;

		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
}


/* STEP PROCESSES

type alias Process =
  { $ : tag
  , id : unique_id
  , root : Task
  , stack : null | { $: SUCCEED | FAIL, a: callback, b: stack }
  , mailbox : [msg]
  }

*/


var _Scheduler_working = false;
var _Scheduler_queue = [];


function _Scheduler_enqueue(proc)
{
	_Scheduler_queue.push(proc);
	if (_Scheduler_working)
	{
		return;
	}
	_Scheduler_working = true;
	while (proc = _Scheduler_queue.shift())
	{
		_Scheduler_step(proc);
	}
	_Scheduler_working = false;
}


function _Scheduler_step(proc)
{
	while (proc.f)
	{
		var rootTag = proc.f.$;
		if (rootTag === 0 || rootTag === 1)
		{
			while (proc.g && proc.g.$ !== rootTag)
			{
				proc.g = proc.g.i;
			}
			if (!proc.g)
			{
				return;
			}
			proc.f = proc.g.b(proc.f.a);
			proc.g = proc.g.i;
		}
		else if (rootTag === 2)
		{
			proc.f.c = proc.f.b(function(newRoot) {
				proc.f = newRoot;
				_Scheduler_enqueue(proc);
			});
			return;
		}
		else if (rootTag === 5)
		{
			if (proc.h.length === 0)
			{
				return;
			}
			proc.f = proc.f.b(proc.h.shift());
		}
		else // if (rootTag === 3 || rootTag === 4)
		{
			proc.g = {
				$: rootTag === 3 ? 0 : 1,
				b: proc.f.b,
				i: proc.g
			};
			proc.f = proc.f.d;
		}
	}
}



function _Process_sleep(time)
{
	return _Scheduler_binding(function(callback) {
		var id = setTimeout(function() {
			callback(_Scheduler_succeed(_Utils_Tuple0));
		}, time);

		return function() { clearTimeout(id); };
	});
}




// PROGRAMS


var _Platform_worker = F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cM,
		impl.dl,
		impl.dh,
		function() { return function() {} }
	);
});



// INITIALIZE A PROGRAM


function _Platform_initialize(flagDecoder, args, init, update, subscriptions, stepperBuilder)
{
	var result = A2(_Json_run, flagDecoder, _Json_wrap(args ? args['flags'] : undefined));
	$elm$core$Result$isOk(result) || _Debug_crash(2 /**_UNUSED/, _Json_errorToString(result.a) /**/);
	var managers = {};
	var initPair = init(result.a);
	var model = initPair.a;
	var stepper = stepperBuilder(sendToApp, model);
	var ports = _Platform_setupEffects(managers, sendToApp);

	function sendToApp(msg, viewMetadata)
	{
		var pair = A2(update, msg, model);
		stepper(model = pair.a, viewMetadata);
		_Platform_enqueueEffects(managers, pair.b, subscriptions(model));
	}

	_Platform_enqueueEffects(managers, initPair.b, subscriptions(model));

	return ports ? { ports: ports } : {};
}



// TRACK PRELOADS
//
// This is used by code in elm/browser and elm/http
// to register any HTTP requests that are triggered by init.
//


var _Platform_preload;


function _Platform_registerPreload(url)
{
	_Platform_preload.add(url);
}



// EFFECT MANAGERS


var _Platform_effectManagers = {};


function _Platform_setupEffects(managers, sendToApp)
{
	var ports;

	// setup all necessary effect managers
	for (var key in _Platform_effectManagers)
	{
		var manager = _Platform_effectManagers[key];

		if (manager.a)
		{
			ports = ports || {};
			ports[key] = manager.a(key, sendToApp);
		}

		managers[key] = _Platform_instantiateManager(manager, sendToApp);
	}

	return ports;
}


function _Platform_createManager(init, onEffects, onSelfMsg, cmdMap, subMap)
{
	return {
		b: init,
		c: onEffects,
		d: onSelfMsg,
		e: cmdMap,
		f: subMap
	};
}


function _Platform_instantiateManager(info, sendToApp)
{
	var router = {
		g: sendToApp,
		h: undefined
	};

	var onEffects = info.c;
	var onSelfMsg = info.d;
	var cmdMap = info.e;
	var subMap = info.f;

	function loop(state)
	{
		return A2(_Scheduler_andThen, loop, _Scheduler_receive(function(msg)
		{
			var value = msg.a;

			if (msg.$ === 0)
			{
				return A3(onSelfMsg, router, value, state);
			}

			return cmdMap && subMap
				? A4(onEffects, router, value.i, value.j, state)
				: A3(onEffects, router, cmdMap ? value.i : value.j, state);
		}));
	}

	return router.h = _Scheduler_rawSpawn(A2(_Scheduler_andThen, loop, info.b));
}



// ROUTING


var _Platform_sendToApp = F2(function(router, msg)
{
	return _Scheduler_binding(function(callback)
	{
		router.g(msg);
		callback(_Scheduler_succeed(_Utils_Tuple0));
	});
});


var _Platform_sendToSelf = F2(function(router, msg)
{
	return A2(_Scheduler_send, router.h, {
		$: 0,
		a: msg
	});
});



// BAGS


function _Platform_leaf(home)
{
	return function(value)
	{
		return {
			$: 1,
			k: home,
			l: value
		};
	};
}


function _Platform_batch(list)
{
	return {
		$: 2,
		m: list
	};
}


var _Platform_map = F2(function(tagger, bag)
{
	return {
		$: 3,
		n: tagger,
		o: bag
	}
});



// PIPE BAGS INTO EFFECT MANAGERS
//
// Effects must be queued!
//
// Say your init contains a synchronous command, like Time.now or Time.here
//
//   - This will produce a batch of effects (FX_1)
//   - The synchronous task triggers the subsequent `update` call
//   - This will produce a batch of effects (FX_2)
//
// If we just start dispatching FX_2, subscriptions from FX_2 can be processed
// before subscriptions from FX_1. No good! Earlier versions of this code had
// this problem, leading to these reports:
//
//   https://github.com/elm/core/issues/980
//   https://github.com/elm/core/pull/981
//   https://github.com/elm/compiler/issues/1776
//
// The queue is necessary to avoid ordering issues for synchronous commands.


// Why use true/false here? Why not just check the length of the queue?
// The goal is to detect "are we currently dispatching effects?" If we
// are, we need to bail and let the ongoing while loop handle things.
//
// Now say the queue has 1 element. When we dequeue the final element,
// the queue will be empty, but we are still actively dispatching effects.
// So you could get queue jumping in a really tricky category of cases.
//
var _Platform_effectsQueue = [];
var _Platform_effectsActive = false;


function _Platform_enqueueEffects(managers, cmdBag, subBag)
{
	_Platform_effectsQueue.push({ p: managers, q: cmdBag, r: subBag });

	if (_Platform_effectsActive) return;

	_Platform_effectsActive = true;
	for (var fx; fx = _Platform_effectsQueue.shift(); )
	{
		_Platform_dispatchEffects(fx.p, fx.q, fx.r);
	}
	_Platform_effectsActive = false;
}


function _Platform_dispatchEffects(managers, cmdBag, subBag)
{
	var effectsDict = {};
	_Platform_gatherEffects(true, cmdBag, effectsDict, null);
	_Platform_gatherEffects(false, subBag, effectsDict, null);

	for (var home in managers)
	{
		_Scheduler_rawSend(managers[home], {
			$: 'fx',
			a: effectsDict[home] || { i: _List_Nil, j: _List_Nil }
		});
	}
}


function _Platform_gatherEffects(isCmd, bag, effectsDict, taggers)
{
	switch (bag.$)
	{
		case 1:
			var home = bag.k;
			var effect = _Platform_toEffect(isCmd, home, taggers, bag.l);
			effectsDict[home] = _Platform_insert(isCmd, effect, effectsDict[home]);
			return;

		case 2:
			for (var list = bag.m; list.b; list = list.b) // WHILE_CONS
			{
				_Platform_gatherEffects(isCmd, list.a, effectsDict, taggers);
			}
			return;

		case 3:
			_Platform_gatherEffects(isCmd, bag.o, effectsDict, {
				s: bag.n,
				t: taggers
			});
			return;
	}
}


function _Platform_toEffect(isCmd, home, taggers, value)
{
	function applyTaggers(x)
	{
		for (var temp = taggers; temp; temp = temp.t)
		{
			x = temp.s(x);
		}
		return x;
	}

	var map = isCmd
		? _Platform_effectManagers[home].e
		: _Platform_effectManagers[home].f;

	return A2(map, applyTaggers, value)
}


function _Platform_insert(isCmd, newEffect, effects)
{
	effects = effects || { i: _List_Nil, j: _List_Nil };

	isCmd
		? (effects.i = _List_Cons(newEffect, effects.i))
		: (effects.j = _List_Cons(newEffect, effects.j));

	return effects;
}



// PORTS


function _Platform_checkPortName(name)
{
	if (_Platform_effectManagers[name])
	{
		_Debug_crash(3, name)
	}
}



// OUTGOING PORTS


function _Platform_outgoingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		e: _Platform_outgoingPortMap,
		u: converter,
		a: _Platform_setupOutgoingPort
	};
	return _Platform_leaf(name);
}


var _Platform_outgoingPortMap = F2(function(tagger, value) { return value; });


function _Platform_setupOutgoingPort(name)
{
	var subs = [];
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Process_sleep(0);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, cmdList, state)
	{
		for ( ; cmdList.b; cmdList = cmdList.b) // WHILE_CONS
		{
			// grab a separate reference to subs in case unsubscribe is called
			var currentSubs = subs;
			var value = _Json_unwrap(converter(cmdList.a));
			for (var i = 0; i < currentSubs.length; i++)
			{
				currentSubs[i](value);
			}
		}
		return init;
	});

	// PUBLIC API

	function subscribe(callback)
	{
		subs.push(callback);
	}

	function unsubscribe(callback)
	{
		// copy subs into a new array in case unsubscribe is called within a
		// subscribed callback
		subs = subs.slice();
		var index = subs.indexOf(callback);
		if (index >= 0)
		{
			subs.splice(index, 1);
		}
	}

	return {
		subscribe: subscribe,
		unsubscribe: unsubscribe
	};
}



// INCOMING PORTS


function _Platform_incomingPort(name, converter)
{
	_Platform_checkPortName(name);
	_Platform_effectManagers[name] = {
		f: _Platform_incomingPortMap,
		u: converter,
		a: _Platform_setupIncomingPort
	};
	return _Platform_leaf(name);
}


var _Platform_incomingPortMap = F2(function(tagger, finalTagger)
{
	return function(value)
	{
		return tagger(finalTagger(value));
	};
});


function _Platform_setupIncomingPort(name, sendToApp)
{
	var subs = _List_Nil;
	var converter = _Platform_effectManagers[name].u;

	// CREATE MANAGER

	var init = _Scheduler_succeed(null);

	_Platform_effectManagers[name].b = init;
	_Platform_effectManagers[name].c = F3(function(router, subList, state)
	{
		subs = subList;
		return init;
	});

	// PUBLIC API

	function send(incomingValue)
	{
		var result = A2(_Json_run, converter, _Json_wrap(incomingValue));

		$elm$core$Result$isOk(result) || _Debug_crash(4, name, result.a);

		var value = result.a;
		for (var temp = subs; temp.b; temp = temp.b) // WHILE_CONS
		{
			sendToApp(temp.a(value));
		}
	}

	return { send: send };
}



// EXPORT ELM MODULES
//
// Have DEBUG and PROD versions so that we can (1) give nicer errors in
// debug mode and (2) not pay for the bits needed for that in prod mode.
//


function _Platform_export(exports)
{
	scope['Elm']
		? _Platform_mergeExportsProd(scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsProd(obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6)
				: _Platform_mergeExportsProd(obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}


function _Platform_export_UNUSED(exports)
{
	scope['Elm']
		? _Platform_mergeExportsDebug('Elm', scope['Elm'], exports)
		: scope['Elm'] = exports;
}


function _Platform_mergeExportsDebug(moduleName, obj, exports)
{
	for (var name in exports)
	{
		(name in obj)
			? (name == 'init')
				? _Debug_crash(6, moduleName)
				: _Platform_mergeExportsDebug(moduleName + '.' + name, obj[name], exports[name])
			: (obj[name] = exports[name]);
	}
}




// HELPERS


var _VirtualDom_divertHrefToApp;

var _VirtualDom_doc = typeof document !== 'undefined' ? document : {};


function _VirtualDom_appendChild(parent, child)
{
	parent.appendChild(child);
}

var _VirtualDom_init = F4(function(virtualNode, flagDecoder, debugMetadata, args)
{
	// NOTE: this function needs _Platform_export available to work

	/**/
	var node = args['node'];
	//*/
	/**_UNUSED/
	var node = args && args['node'] ? args['node'] : _Debug_crash(0);
	//*/

	node.parentNode.replaceChild(
		_VirtualDom_render(virtualNode, function() {}),
		node
	);

	return {};
});



// TEXT


function _VirtualDom_text(string)
{
	return {
		$: 0,
		a: string
	};
}



// NODE


var _VirtualDom_nodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 1,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_node = _VirtualDom_nodeNS(undefined);



// KEYED NODE


var _VirtualDom_keyedNodeNS = F2(function(namespace, tag)
{
	return F2(function(factList, kidList)
	{
		for (var kids = [], descendantsCount = 0; kidList.b; kidList = kidList.b) // WHILE_CONS
		{
			var kid = kidList.a;
			descendantsCount += (kid.b.b || 0);
			kids.push(kid);
		}
		descendantsCount += kids.length;

		return {
			$: 2,
			c: tag,
			d: _VirtualDom_organizeFacts(factList),
			e: kids,
			f: namespace,
			b: descendantsCount
		};
	});
});


var _VirtualDom_keyedNode = _VirtualDom_keyedNodeNS(undefined);



// CUSTOM


function _VirtualDom_custom(factList, model, render, diff)
{
	return {
		$: 3,
		d: _VirtualDom_organizeFacts(factList),
		g: model,
		h: render,
		i: diff
	};
}



// MAP


var _VirtualDom_map = F2(function(tagger, node)
{
	return {
		$: 4,
		j: tagger,
		k: node,
		b: 1 + (node.b || 0)
	};
});



// LAZY


function _VirtualDom_thunk(refs, thunk)
{
	return {
		$: 5,
		l: refs,
		m: thunk,
		k: undefined
	};
}

var _VirtualDom_lazy = F2(function(func, a)
{
	return _VirtualDom_thunk([func, a], function() {
		return func(a);
	});
});

var _VirtualDom_lazy2 = F3(function(func, a, b)
{
	return _VirtualDom_thunk([func, a, b], function() {
		return A2(func, a, b);
	});
});

var _VirtualDom_lazy3 = F4(function(func, a, b, c)
{
	return _VirtualDom_thunk([func, a, b, c], function() {
		return A3(func, a, b, c);
	});
});

var _VirtualDom_lazy4 = F5(function(func, a, b, c, d)
{
	return _VirtualDom_thunk([func, a, b, c, d], function() {
		return A4(func, a, b, c, d);
	});
});

var _VirtualDom_lazy5 = F6(function(func, a, b, c, d, e)
{
	return _VirtualDom_thunk([func, a, b, c, d, e], function() {
		return A5(func, a, b, c, d, e);
	});
});

var _VirtualDom_lazy6 = F7(function(func, a, b, c, d, e, f)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f], function() {
		return A6(func, a, b, c, d, e, f);
	});
});

var _VirtualDom_lazy7 = F8(function(func, a, b, c, d, e, f, g)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g], function() {
		return A7(func, a, b, c, d, e, f, g);
	});
});

var _VirtualDom_lazy8 = F9(function(func, a, b, c, d, e, f, g, h)
{
	return _VirtualDom_thunk([func, a, b, c, d, e, f, g, h], function() {
		return A8(func, a, b, c, d, e, f, g, h);
	});
});



// FACTS


var _VirtualDom_on = F2(function(key, handler)
{
	return {
		$: 'a0',
		n: key,
		o: handler
	};
});
var _VirtualDom_style = F2(function(key, value)
{
	return {
		$: 'a1',
		n: key,
		o: value
	};
});
var _VirtualDom_property = F2(function(key, value)
{
	return {
		$: 'a2',
		n: key,
		o: value
	};
});
var _VirtualDom_attribute = F2(function(key, value)
{
	return {
		$: 'a3',
		n: key,
		o: value
	};
});
var _VirtualDom_attributeNS = F3(function(namespace, key, value)
{
	return {
		$: 'a4',
		n: key,
		o: { f: namespace, o: value }
	};
});



// XSS ATTACK VECTOR CHECKS
//
// For some reason, tabs can appear in href protocols and it still works.
// So '\tjava\tSCRIPT:alert("!!!")' and 'javascript:alert("!!!")' are the same
// in practice. That is why _VirtualDom_RE_js and _VirtualDom_RE_js_html look
// so freaky.
//
// Pulling the regular expressions out to the top level gives a slight speed
// boost in small benchmarks (4-10%) but hoisting values to reduce allocation
// can be unpredictable in large programs where JIT may have a harder time with
// functions are not fully self-contained. The benefit is more that the js and
// js_html ones are so weird that I prefer to see them near each other.


var _VirtualDom_RE_script = /^script$/i;
var _VirtualDom_RE_on_formAction = /^(on|formAction$)/i;
var _VirtualDom_RE_js = /^\s*j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:/i;
var _VirtualDom_RE_js_html = /^\s*(j\s*a\s*v\s*a\s*s\s*c\s*r\s*i\s*p\s*t\s*:|d\s*a\s*t\s*a\s*:\s*t\s*e\s*x\s*t\s*\/\s*h\s*t\s*m\s*l\s*(,|;))/i;


function _VirtualDom_noScript(tag)
{
	return _VirtualDom_RE_script.test(tag) ? 'p' : tag;
}

function _VirtualDom_noOnOrFormAction(key)
{
	return _VirtualDom_RE_on_formAction.test(key) ? 'data-' + key : key;
}

function _VirtualDom_noInnerHtmlOrFormAction(key)
{
	return key == 'innerHTML' || key == 'formAction' ? 'data-' + key : key;
}

function _VirtualDom_noJavaScriptUri(value)
{
	return _VirtualDom_RE_js.test(value)
		? /**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlUri(value)
{
	return _VirtualDom_RE_js_html.test(value)
		? /**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		: value;
}

function _VirtualDom_noJavaScriptOrHtmlJson(value)
{
	return (typeof _Json_unwrap(value) === 'string' && _VirtualDom_RE_js_html.test(_Json_unwrap(value)))
		? _Json_wrap(
			/**/''//*//**_UNUSED/'javascript:alert("This is an XSS vector. Please use ports or web components instead.")'//*/
		) : value;
}



// MAP FACTS


var _VirtualDom_mapAttribute = F2(function(func, attr)
{
	return (attr.$ === 'a0')
		? A2(_VirtualDom_on, attr.n, _VirtualDom_mapHandler(func, attr.o))
		: attr;
});

function _VirtualDom_mapHandler(func, handler)
{
	var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

	// 0 = Normal
	// 1 = MayStopPropagation
	// 2 = MayPreventDefault
	// 3 = Custom

	return {
		$: handler.$,
		a:
			!tag
				? A2($elm$json$Json$Decode$map, func, handler.a)
				:
			A3($elm$json$Json$Decode$map2,
				tag < 3
					? _VirtualDom_mapEventTuple
					: _VirtualDom_mapEventRecord,
				$elm$json$Json$Decode$succeed(func),
				handler.a
			)
	};
}

var _VirtualDom_mapEventTuple = F2(function(func, tuple)
{
	return _Utils_Tuple2(func(tuple.a), tuple.b);
});

var _VirtualDom_mapEventRecord = F2(function(func, record)
{
	return {
		Y: func(record.Y),
		bg: record.bg,
		bc: record.bc
	}
});



// ORGANIZE FACTS


function _VirtualDom_organizeFacts(factList)
{
	for (var facts = {}; factList.b; factList = factList.b) // WHILE_CONS
	{
		var entry = factList.a;

		var tag = entry.$;
		var key = entry.n;
		var value = entry.o;

		if (tag === 'a2')
		{
			(key === 'className')
				? _VirtualDom_addClass(facts, key, _Json_unwrap(value))
				: facts[key] = _Json_unwrap(value);

			continue;
		}

		var subFacts = facts[tag] || (facts[tag] = {});
		(tag === 'a3' && key === 'class')
			? _VirtualDom_addClass(subFacts, key, value)
			: subFacts[key] = value;
	}

	return facts;
}

function _VirtualDom_addClass(object, key, newClass)
{
	var classes = object[key];
	object[key] = classes ? classes + ' ' + newClass : newClass;
}



// RENDER


function _VirtualDom_render(vNode, eventNode)
{
	var tag = vNode.$;

	if (tag === 5)
	{
		return _VirtualDom_render(vNode.k || (vNode.k = vNode.m()), eventNode);
	}

	if (tag === 0)
	{
		return _VirtualDom_doc.createTextNode(vNode.a);
	}

	if (tag === 4)
	{
		var subNode = vNode.k;
		var tagger = vNode.j;

		while (subNode.$ === 4)
		{
			typeof tagger !== 'object'
				? tagger = [tagger, subNode.j]
				: tagger.push(subNode.j);

			subNode = subNode.k;
		}

		var subEventRoot = { j: tagger, p: eventNode };
		var domNode = _VirtualDom_render(subNode, subEventRoot);
		domNode.elm_event_node_ref = subEventRoot;
		return domNode;
	}

	if (tag === 3)
	{
		var domNode = vNode.h(vNode.g);
		_VirtualDom_applyFacts(domNode, eventNode, vNode.d);
		return domNode;
	}

	// at this point `tag` must be 1 or 2

	var domNode = vNode.f
		? _VirtualDom_doc.createElementNS(vNode.f, vNode.c)
		: _VirtualDom_doc.createElement(vNode.c);

	if (_VirtualDom_divertHrefToApp && vNode.c == 'a')
	{
		domNode.addEventListener('click', _VirtualDom_divertHrefToApp(domNode));
	}

	_VirtualDom_applyFacts(domNode, eventNode, vNode.d);

	for (var kids = vNode.e, i = 0; i < kids.length; i++)
	{
		_VirtualDom_appendChild(domNode, _VirtualDom_render(tag === 1 ? kids[i] : kids[i].b, eventNode));
	}

	return domNode;
}



// APPLY FACTS


function _VirtualDom_applyFacts(domNode, eventNode, facts)
{
	for (var key in facts)
	{
		var value = facts[key];

		key === 'a1'
			? _VirtualDom_applyStyles(domNode, value)
			:
		key === 'a0'
			? _VirtualDom_applyEvents(domNode, eventNode, value)
			:
		key === 'a3'
			? _VirtualDom_applyAttrs(domNode, value)
			:
		key === 'a4'
			? _VirtualDom_applyAttrsNS(domNode, value)
			:
		((key !== 'value' && key !== 'checked') || domNode[key] !== value) && (domNode[key] = value);
	}
}



// APPLY STYLES


function _VirtualDom_applyStyles(domNode, styles)
{
	var domNodeStyle = domNode.style;

	for (var key in styles)
	{
		domNodeStyle[key] = styles[key];
	}
}



// APPLY ATTRS


function _VirtualDom_applyAttrs(domNode, attrs)
{
	for (var key in attrs)
	{
		var value = attrs[key];
		typeof value !== 'undefined'
			? domNode.setAttribute(key, value)
			: domNode.removeAttribute(key);
	}
}



// APPLY NAMESPACED ATTRS


function _VirtualDom_applyAttrsNS(domNode, nsAttrs)
{
	for (var key in nsAttrs)
	{
		var pair = nsAttrs[key];
		var namespace = pair.f;
		var value = pair.o;

		typeof value !== 'undefined'
			? domNode.setAttributeNS(namespace, key, value)
			: domNode.removeAttributeNS(namespace, key);
	}
}



// APPLY EVENTS


function _VirtualDom_applyEvents(domNode, eventNode, events)
{
	var allCallbacks = domNode.elmFs || (domNode.elmFs = {});

	for (var key in events)
	{
		var newHandler = events[key];
		var oldCallback = allCallbacks[key];

		if (!newHandler)
		{
			domNode.removeEventListener(key, oldCallback);
			allCallbacks[key] = undefined;
			continue;
		}

		if (oldCallback)
		{
			var oldHandler = oldCallback.q;
			if (oldHandler.$ === newHandler.$)
			{
				oldCallback.q = newHandler;
				continue;
			}
			domNode.removeEventListener(key, oldCallback);
		}

		oldCallback = _VirtualDom_makeCallback(eventNode, newHandler);
		domNode.addEventListener(key, oldCallback,
			_VirtualDom_passiveSupported
			&& { passive: $elm$virtual_dom$VirtualDom$toHandlerInt(newHandler) < 2 }
		);
		allCallbacks[key] = oldCallback;
	}
}



// PASSIVE EVENTS


var _VirtualDom_passiveSupported;

try
{
	window.addEventListener('t', null, Object.defineProperty({}, 'passive', {
		get: function() { _VirtualDom_passiveSupported = true; }
	}));
}
catch(e) {}



// EVENT HANDLERS


function _VirtualDom_makeCallback(eventNode, initialHandler)
{
	function callback(event)
	{
		var handler = callback.q;
		var result = _Json_runHelp(handler.a, event);

		if (!$elm$core$Result$isOk(result))
		{
			return;
		}

		var tag = $elm$virtual_dom$VirtualDom$toHandlerInt(handler);

		// 0 = Normal
		// 1 = MayStopPropagation
		// 2 = MayPreventDefault
		// 3 = Custom

		var value = result.a;
		var message = !tag ? value : tag < 3 ? value.a : value.Y;
		var stopPropagation = tag == 1 ? value.b : tag == 3 && value.bg;
		var currentEventNode = (
			stopPropagation && event.stopPropagation(),
			(tag == 2 ? value.b : tag == 3 && value.bc) && event.preventDefault(),
			eventNode
		);
		var tagger;
		var i;
		while (tagger = currentEventNode.j)
		{
			if (typeof tagger == 'function')
			{
				message = tagger(message);
			}
			else
			{
				for (var i = tagger.length; i--; )
				{
					message = tagger[i](message);
				}
			}
			currentEventNode = currentEventNode.p;
		}
		currentEventNode(message, stopPropagation); // stopPropagation implies isSync
	}

	callback.q = initialHandler;

	return callback;
}

function _VirtualDom_equalEvents(x, y)
{
	return x.$ == y.$ && _Json_equality(x.a, y.a);
}



// DIFF


// TODO: Should we do patches like in iOS?
//
// type Patch
//   = At Int Patch
//   | Batch (List Patch)
//   | Change ...
//
// How could it not be better?
//
function _VirtualDom_diff(x, y)
{
	var patches = [];
	_VirtualDom_diffHelp(x, y, patches, 0);
	return patches;
}


function _VirtualDom_pushPatch(patches, type, index, data)
{
	var patch = {
		$: type,
		r: index,
		s: data,
		t: undefined,
		u: undefined
	};
	patches.push(patch);
	return patch;
}


function _VirtualDom_diffHelp(x, y, patches, index)
{
	if (x === y)
	{
		return;
	}

	var xType = x.$;
	var yType = y.$;

	// Bail if you run into different types of nodes. Implies that the
	// structure has changed significantly and it's not worth a diff.
	if (xType !== yType)
	{
		if (xType === 1 && yType === 2)
		{
			y = _VirtualDom_dekey(y);
			yType = 1;
		}
		else
		{
			_VirtualDom_pushPatch(patches, 0, index, y);
			return;
		}
	}

	// Now we know that both nodes are the same $.
	switch (yType)
	{
		case 5:
			var xRefs = x.l;
			var yRefs = y.l;
			var i = xRefs.length;
			var same = i === yRefs.length;
			while (same && i--)
			{
				same = xRefs[i] === yRefs[i];
			}
			if (same)
			{
				y.k = x.k;
				return;
			}
			y.k = y.m();
			var subPatches = [];
			_VirtualDom_diffHelp(x.k, y.k, subPatches, 0);
			subPatches.length > 0 && _VirtualDom_pushPatch(patches, 1, index, subPatches);
			return;

		case 4:
			// gather nested taggers
			var xTaggers = x.j;
			var yTaggers = y.j;
			var nesting = false;

			var xSubNode = x.k;
			while (xSubNode.$ === 4)
			{
				nesting = true;

				typeof xTaggers !== 'object'
					? xTaggers = [xTaggers, xSubNode.j]
					: xTaggers.push(xSubNode.j);

				xSubNode = xSubNode.k;
			}

			var ySubNode = y.k;
			while (ySubNode.$ === 4)
			{
				nesting = true;

				typeof yTaggers !== 'object'
					? yTaggers = [yTaggers, ySubNode.j]
					: yTaggers.push(ySubNode.j);

				ySubNode = ySubNode.k;
			}

			// Just bail if different numbers of taggers. This implies the
			// structure of the virtual DOM has changed.
			if (nesting && xTaggers.length !== yTaggers.length)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			// check if taggers are "the same"
			if (nesting ? !_VirtualDom_pairwiseRefEqual(xTaggers, yTaggers) : xTaggers !== yTaggers)
			{
				_VirtualDom_pushPatch(patches, 2, index, yTaggers);
			}

			// diff everything below the taggers
			_VirtualDom_diffHelp(xSubNode, ySubNode, patches, index + 1);
			return;

		case 0:
			if (x.a !== y.a)
			{
				_VirtualDom_pushPatch(patches, 3, index, y.a);
			}
			return;

		case 1:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKids);
			return;

		case 2:
			_VirtualDom_diffNodes(x, y, patches, index, _VirtualDom_diffKeyedKids);
			return;

		case 3:
			if (x.h !== y.h)
			{
				_VirtualDom_pushPatch(patches, 0, index, y);
				return;
			}

			var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
			factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

			var patch = y.i(x.g, y.g);
			patch && _VirtualDom_pushPatch(patches, 5, index, patch);

			return;
	}
}

// assumes the incoming arrays are the same length
function _VirtualDom_pairwiseRefEqual(as, bs)
{
	for (var i = 0; i < as.length; i++)
	{
		if (as[i] !== bs[i])
		{
			return false;
		}
	}

	return true;
}

function _VirtualDom_diffNodes(x, y, patches, index, diffKids)
{
	// Bail if obvious indicators have changed. Implies more serious
	// structural changes such that it's not worth it to diff.
	if (x.c !== y.c || x.f !== y.f)
	{
		_VirtualDom_pushPatch(patches, 0, index, y);
		return;
	}

	var factsDiff = _VirtualDom_diffFacts(x.d, y.d);
	factsDiff && _VirtualDom_pushPatch(patches, 4, index, factsDiff);

	diffKids(x, y, patches, index);
}



// DIFF FACTS


// TODO Instead of creating a new diff object, it's possible to just test if
// there *is* a diff. During the actual patch, do the diff again and make the
// modifications directly. This way, there's no new allocations. Worth it?
function _VirtualDom_diffFacts(x, y, category)
{
	var diff;

	// look for changes and removals
	for (var xKey in x)
	{
		if (xKey === 'a1' || xKey === 'a0' || xKey === 'a3' || xKey === 'a4')
		{
			var subDiff = _VirtualDom_diffFacts(x[xKey], y[xKey] || {}, xKey);
			if (subDiff)
			{
				diff = diff || {};
				diff[xKey] = subDiff;
			}
			continue;
		}

		// remove if not in the new facts
		if (!(xKey in y))
		{
			diff = diff || {};
			diff[xKey] =
				!category
					? (typeof x[xKey] === 'string' ? '' : null)
					:
				(category === 'a1')
					? ''
					:
				(category === 'a0' || category === 'a3')
					? undefined
					:
				{ f: x[xKey].f, o: undefined };

			continue;
		}

		var xValue = x[xKey];
		var yValue = y[xKey];

		// reference equal, so don't worry about it
		if (xValue === yValue && xKey !== 'value' && xKey !== 'checked'
			|| category === 'a0' && _VirtualDom_equalEvents(xValue, yValue))
		{
			continue;
		}

		diff = diff || {};
		diff[xKey] = yValue;
	}

	// add new stuff
	for (var yKey in y)
	{
		if (!(yKey in x))
		{
			diff = diff || {};
			diff[yKey] = y[yKey];
		}
	}

	return diff;
}



// DIFF KIDS


function _VirtualDom_diffKids(xParent, yParent, patches, index)
{
	var xKids = xParent.e;
	var yKids = yParent.e;

	var xLen = xKids.length;
	var yLen = yKids.length;

	// FIGURE OUT IF THERE ARE INSERTS OR REMOVALS

	if (xLen > yLen)
	{
		_VirtualDom_pushPatch(patches, 6, index, {
			v: yLen,
			i: xLen - yLen
		});
	}
	else if (xLen < yLen)
	{
		_VirtualDom_pushPatch(patches, 7, index, {
			v: xLen,
			e: yKids
		});
	}

	// PAIRWISE DIFF EVERYTHING ELSE

	for (var minLen = xLen < yLen ? xLen : yLen, i = 0; i < minLen; i++)
	{
		var xKid = xKids[i];
		_VirtualDom_diffHelp(xKid, yKids[i], patches, ++index);
		index += xKid.b || 0;
	}
}



// KEYED DIFF


function _VirtualDom_diffKeyedKids(xParent, yParent, patches, rootIndex)
{
	var localPatches = [];

	var changes = {}; // Dict String Entry
	var inserts = []; // Array { index : Int, entry : Entry }
	// type Entry = { tag : String, vnode : VNode, index : Int, data : _ }

	var xKids = xParent.e;
	var yKids = yParent.e;
	var xLen = xKids.length;
	var yLen = yKids.length;
	var xIndex = 0;
	var yIndex = 0;

	var index = rootIndex;

	while (xIndex < xLen && yIndex < yLen)
	{
		var x = xKids[xIndex];
		var y = yKids[yIndex];

		var xKey = x.a;
		var yKey = y.a;
		var xNode = x.b;
		var yNode = y.b;

		var newMatch = undefined;
		var oldMatch = undefined;

		// check if keys match

		if (xKey === yKey)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNode, localPatches, index);
			index += xNode.b || 0;

			xIndex++;
			yIndex++;
			continue;
		}

		// look ahead 1 to detect insertions and removals.

		var xNext = xKids[xIndex + 1];
		var yNext = yKids[yIndex + 1];

		if (xNext)
		{
			var xNextKey = xNext.a;
			var xNextNode = xNext.b;
			oldMatch = yKey === xNextKey;
		}

		if (yNext)
		{
			var yNextKey = yNext.a;
			var yNextNode = yNext.b;
			newMatch = xKey === yNextKey;
		}


		// swap x and y
		if (newMatch && oldMatch)
		{
			index++;
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			_VirtualDom_insertNode(changes, localPatches, xKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNextNode, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		// insert y
		if (newMatch)
		{
			index++;
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			_VirtualDom_diffHelp(xNode, yNextNode, localPatches, index);
			index += xNode.b || 0;

			xIndex += 1;
			yIndex += 2;
			continue;
		}

		// remove x
		if (oldMatch)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 1;
			continue;
		}

		// remove x, insert y
		if (xNext && xNextKey === yNextKey)
		{
			index++;
			_VirtualDom_removeNode(changes, localPatches, xKey, xNode, index);
			_VirtualDom_insertNode(changes, localPatches, yKey, yNode, yIndex, inserts);
			index += xNode.b || 0;

			index++;
			_VirtualDom_diffHelp(xNextNode, yNextNode, localPatches, index);
			index += xNextNode.b || 0;

			xIndex += 2;
			yIndex += 2;
			continue;
		}

		break;
	}

	// eat up any remaining nodes with removeNode and insertNode

	while (xIndex < xLen)
	{
		index++;
		var x = xKids[xIndex];
		var xNode = x.b;
		_VirtualDom_removeNode(changes, localPatches, x.a, xNode, index);
		index += xNode.b || 0;
		xIndex++;
	}

	while (yIndex < yLen)
	{
		var endInserts = endInserts || [];
		var y = yKids[yIndex];
		_VirtualDom_insertNode(changes, localPatches, y.a, y.b, undefined, endInserts);
		yIndex++;
	}

	if (localPatches.length > 0 || inserts.length > 0 || endInserts)
	{
		_VirtualDom_pushPatch(patches, 8, rootIndex, {
			w: localPatches,
			x: inserts,
			y: endInserts
		});
	}
}



// CHANGES FROM KEYED DIFF


var _VirtualDom_POSTFIX = '_elmW6BL';


function _VirtualDom_insertNode(changes, localPatches, key, vnode, yIndex, inserts)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		entry = {
			c: 0,
			z: vnode,
			r: yIndex,
			s: undefined
		};

		inserts.push({ r: yIndex, A: entry });
		changes[key] = entry;

		return;
	}

	// this key was removed earlier, a match!
	if (entry.c === 1)
	{
		inserts.push({ r: yIndex, A: entry });

		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(entry.z, vnode, subPatches, entry.r);
		entry.r = yIndex;
		entry.s.s = {
			w: subPatches,
			A: entry
		};

		return;
	}

	// this key has already been inserted or moved, a duplicate!
	_VirtualDom_insertNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, yIndex, inserts);
}


function _VirtualDom_removeNode(changes, localPatches, key, vnode, index)
{
	var entry = changes[key];

	// never seen this key before
	if (!entry)
	{
		var patch = _VirtualDom_pushPatch(localPatches, 9, index, undefined);

		changes[key] = {
			c: 1,
			z: vnode,
			r: index,
			s: patch
		};

		return;
	}

	// this key was inserted earlier, a match!
	if (entry.c === 0)
	{
		entry.c = 2;
		var subPatches = [];
		_VirtualDom_diffHelp(vnode, entry.z, subPatches, index);

		_VirtualDom_pushPatch(localPatches, 9, index, {
			w: subPatches,
			A: entry
		});

		return;
	}

	// this key has already been removed or moved, a duplicate!
	_VirtualDom_removeNode(changes, localPatches, key + _VirtualDom_POSTFIX, vnode, index);
}



// ADD DOM NODES
//
// Each DOM node has an "index" assigned in order of traversal. It is important
// to minimize our crawl over the actual DOM, so these indexes (along with the
// descendantsCount of virtual nodes) let us skip touching entire subtrees of
// the DOM if we know there are no patches there.


function _VirtualDom_addDomNodes(domNode, vNode, patches, eventNode)
{
	_VirtualDom_addDomNodesHelp(domNode, vNode, patches, 0, 0, vNode.b, eventNode);
}


// assumes `patches` is non-empty and indexes increase monotonically.
function _VirtualDom_addDomNodesHelp(domNode, vNode, patches, i, low, high, eventNode)
{
	var patch = patches[i];
	var index = patch.r;

	while (index === low)
	{
		var patchType = patch.$;

		if (patchType === 1)
		{
			_VirtualDom_addDomNodes(domNode, vNode.k, patch.s, eventNode);
		}
		else if (patchType === 8)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var subPatches = patch.s.w;
			if (subPatches.length > 0)
			{
				_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
			}
		}
		else if (patchType === 9)
		{
			patch.t = domNode;
			patch.u = eventNode;

			var data = patch.s;
			if (data)
			{
				data.A.s = domNode;
				var subPatches = data.w;
				if (subPatches.length > 0)
				{
					_VirtualDom_addDomNodesHelp(domNode, vNode, subPatches, 0, low, high, eventNode);
				}
			}
		}
		else
		{
			patch.t = domNode;
			patch.u = eventNode;
		}

		i++;

		if (!(patch = patches[i]) || (index = patch.r) > high)
		{
			return i;
		}
	}

	var tag = vNode.$;

	if (tag === 4)
	{
		var subNode = vNode.k;

		while (subNode.$ === 4)
		{
			subNode = subNode.k;
		}

		return _VirtualDom_addDomNodesHelp(domNode, subNode, patches, i, low + 1, high, domNode.elm_event_node_ref);
	}

	// tag must be 1 or 2 at this point

	var vKids = vNode.e;
	var childNodes = domNode.childNodes;
	for (var j = 0; j < vKids.length; j++)
	{
		low++;
		var vKid = tag === 1 ? vKids[j] : vKids[j].b;
		var nextLow = low + (vKid.b || 0);
		if (low <= index && index <= nextLow)
		{
			i = _VirtualDom_addDomNodesHelp(childNodes[j], vKid, patches, i, low, nextLow, eventNode);
			if (!(patch = patches[i]) || (index = patch.r) > high)
			{
				return i;
			}
		}
		low = nextLow;
	}
	return i;
}



// APPLY PATCHES


function _VirtualDom_applyPatches(rootDomNode, oldVirtualNode, patches, eventNode)
{
	if (patches.length === 0)
	{
		return rootDomNode;
	}

	_VirtualDom_addDomNodes(rootDomNode, oldVirtualNode, patches, eventNode);
	return _VirtualDom_applyPatchesHelp(rootDomNode, patches);
}

function _VirtualDom_applyPatchesHelp(rootDomNode, patches)
{
	for (var i = 0; i < patches.length; i++)
	{
		var patch = patches[i];
		var localDomNode = patch.t
		var newNode = _VirtualDom_applyPatch(localDomNode, patch);
		if (localDomNode === rootDomNode)
		{
			rootDomNode = newNode;
		}
	}
	return rootDomNode;
}

function _VirtualDom_applyPatch(domNode, patch)
{
	switch (patch.$)
	{
		case 0:
			return _VirtualDom_applyPatchRedraw(domNode, patch.s, patch.u);

		case 4:
			_VirtualDom_applyFacts(domNode, patch.u, patch.s);
			return domNode;

		case 3:
			domNode.replaceData(0, domNode.length, patch.s);
			return domNode;

		case 1:
			return _VirtualDom_applyPatchesHelp(domNode, patch.s);

		case 2:
			if (domNode.elm_event_node_ref)
			{
				domNode.elm_event_node_ref.j = patch.s;
			}
			else
			{
				domNode.elm_event_node_ref = { j: patch.s, p: patch.u };
			}
			return domNode;

		case 6:
			var data = patch.s;
			for (var i = 0; i < data.i; i++)
			{
				domNode.removeChild(domNode.childNodes[data.v]);
			}
			return domNode;

		case 7:
			var data = patch.s;
			var kids = data.e;
			var i = data.v;
			var theEnd = domNode.childNodes[i];
			for (; i < kids.length; i++)
			{
				domNode.insertBefore(_VirtualDom_render(kids[i], patch.u), theEnd);
			}
			return domNode;

		case 9:
			var data = patch.s;
			if (!data)
			{
				domNode.parentNode.removeChild(domNode);
				return domNode;
			}
			var entry = data.A;
			if (typeof entry.r !== 'undefined')
			{
				domNode.parentNode.removeChild(domNode);
			}
			entry.s = _VirtualDom_applyPatchesHelp(domNode, data.w);
			return domNode;

		case 8:
			return _VirtualDom_applyPatchReorder(domNode, patch);

		case 5:
			return patch.s(domNode);

		default:
			_Debug_crash(10); // 'Ran into an unknown patch!'
	}
}


function _VirtualDom_applyPatchRedraw(domNode, vNode, eventNode)
{
	var parentNode = domNode.parentNode;
	var newNode = _VirtualDom_render(vNode, eventNode);

	if (!newNode.elm_event_node_ref)
	{
		newNode.elm_event_node_ref = domNode.elm_event_node_ref;
	}

	if (parentNode && newNode !== domNode)
	{
		parentNode.replaceChild(newNode, domNode);
	}
	return newNode;
}


function _VirtualDom_applyPatchReorder(domNode, patch)
{
	var data = patch.s;

	// remove end inserts
	var frag = _VirtualDom_applyPatchReorderEndInsertsHelp(data.y, patch);

	// removals
	domNode = _VirtualDom_applyPatchesHelp(domNode, data.w);

	// inserts
	var inserts = data.x;
	for (var i = 0; i < inserts.length; i++)
	{
		var insert = inserts[i];
		var entry = insert.A;
		var node = entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u);
		domNode.insertBefore(node, domNode.childNodes[insert.r]);
	}

	// add end inserts
	if (frag)
	{
		_VirtualDom_appendChild(domNode, frag);
	}

	return domNode;
}


function _VirtualDom_applyPatchReorderEndInsertsHelp(endInserts, patch)
{
	if (!endInserts)
	{
		return;
	}

	var frag = _VirtualDom_doc.createDocumentFragment();
	for (var i = 0; i < endInserts.length; i++)
	{
		var insert = endInserts[i];
		var entry = insert.A;
		_VirtualDom_appendChild(frag, entry.c === 2
			? entry.s
			: _VirtualDom_render(entry.z, patch.u)
		);
	}
	return frag;
}


function _VirtualDom_virtualize(node)
{
	// TEXT NODES

	if (node.nodeType === 3)
	{
		return _VirtualDom_text(node.textContent);
	}


	// WEIRD NODES

	if (node.nodeType !== 1)
	{
		return _VirtualDom_text('');
	}


	// ELEMENT NODES

	var attrList = _List_Nil;
	var attrs = node.attributes;
	for (var i = attrs.length; i--; )
	{
		var attr = attrs[i];
		var name = attr.name;
		var value = attr.value;
		attrList = _List_Cons( A2(_VirtualDom_attribute, name, value), attrList );
	}

	var tag = node.tagName.toLowerCase();
	var kidList = _List_Nil;
	var kids = node.childNodes;

	for (var i = kids.length; i--; )
	{
		kidList = _List_Cons(_VirtualDom_virtualize(kids[i]), kidList);
	}
	return A3(_VirtualDom_node, tag, attrList, kidList);
}

function _VirtualDom_dekey(keyedNode)
{
	var keyedKids = keyedNode.e;
	var len = keyedKids.length;
	var kids = new Array(len);
	for (var i = 0; i < len; i++)
	{
		kids[i] = keyedKids[i].b;
	}

	return {
		$: 1,
		c: keyedNode.c,
		d: keyedNode.d,
		e: kids,
		f: keyedNode.f,
		b: keyedNode.b
	};
}




// ELEMENT


var _Debugger_element;

var _Browser_element = _Debugger_element || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cM,
		impl.dl,
		impl.dh,
		function(sendToApp, initialModel) {
			var view = impl.dn;
			/**/
			var domNode = args['node'];
			//*/
			/**_UNUSED/
			var domNode = args && args['node'] ? args['node'] : _Debug_crash(0);
			//*/
			var currNode = _VirtualDom_virtualize(domNode);

			return _Browser_makeAnimator(initialModel, function(model)
			{
				var nextNode = view(model);
				var patches = _VirtualDom_diff(currNode, nextNode);
				domNode = _VirtualDom_applyPatches(domNode, currNode, patches, sendToApp);
				currNode = nextNode;
			});
		}
	);
});



// DOCUMENT


var _Debugger_document;

var _Browser_document = _Debugger_document || F4(function(impl, flagDecoder, debugMetadata, args)
{
	return _Platform_initialize(
		flagDecoder,
		args,
		impl.cM,
		impl.dl,
		impl.dh,
		function(sendToApp, initialModel) {
			var divertHrefToApp = impl.bd && impl.bd(sendToApp)
			var view = impl.dn;
			var title = _VirtualDom_doc.title;
			var bodyNode = _VirtualDom_doc.body;
			var currNode = _VirtualDom_virtualize(bodyNode);
			return _Browser_makeAnimator(initialModel, function(model)
			{
				_VirtualDom_divertHrefToApp = divertHrefToApp;
				var doc = view(model);
				var nextNode = _VirtualDom_node('body')(_List_Nil)(doc.z);
				var patches = _VirtualDom_diff(currNode, nextNode);
				bodyNode = _VirtualDom_applyPatches(bodyNode, currNode, patches, sendToApp);
				currNode = nextNode;
				_VirtualDom_divertHrefToApp = 0;
				(title !== doc.bi) && (_VirtualDom_doc.title = title = doc.bi);
			});
		}
	);
});



// ANIMATION


var _Browser_cancelAnimationFrame =
	typeof cancelAnimationFrame !== 'undefined'
		? cancelAnimationFrame
		: function(id) { clearTimeout(id); };

var _Browser_requestAnimationFrame =
	typeof requestAnimationFrame !== 'undefined'
		? requestAnimationFrame
		: function(callback) { return setTimeout(callback, 1000 / 60); };


function _Browser_makeAnimator(model, draw)
{
	draw(model);

	var state = 0;

	function updateIfNeeded()
	{
		state = state === 1
			? 0
			: ( _Browser_requestAnimationFrame(updateIfNeeded), draw(model), 1 );
	}

	return function(nextModel, isSync)
	{
		model = nextModel;

		isSync
			? ( draw(model),
				state === 2 && (state = 1)
				)
			: ( state === 0 && _Browser_requestAnimationFrame(updateIfNeeded),
				state = 2
				);
	};
}



// APPLICATION


function _Browser_application(impl)
{
	var onUrlChange = impl.c2;
	var onUrlRequest = impl.c3;
	var key = function() { key.a(onUrlChange(_Browser_getUrl())); };

	return _Browser_document({
		bd: function(sendToApp)
		{
			key.a = sendToApp;
			_Browser_window.addEventListener('popstate', key);
			_Browser_window.navigator.userAgent.indexOf('Trident') < 0 || _Browser_window.addEventListener('hashchange', key);

			return F2(function(domNode, event)
			{
				if (!event.ctrlKey && !event.metaKey && !event.shiftKey && event.button < 1 && !domNode.target && !domNode.hasAttribute('download'))
				{
					event.preventDefault();
					var href = domNode.href;
					var curr = _Browser_getUrl();
					var next = $elm$url$Url$fromString(href).a;
					sendToApp(onUrlRequest(
						(next
							&& curr.b_ === next.b_
							&& curr.bH === next.bH
							&& curr.bW.a === next.bW.a
						)
							? $elm$browser$Browser$Internal(next)
							: $elm$browser$Browser$External(href)
					));
				}
			});
		},
		cM: function(flags)
		{
			return A3(impl.cM, flags, _Browser_getUrl(), key);
		},
		dn: impl.dn,
		dl: impl.dl,
		dh: impl.dh
	});
}

function _Browser_getUrl()
{
	return $elm$url$Url$fromString(_VirtualDom_doc.location.href).a || _Debug_crash(1);
}

var _Browser_go = F2(function(key, n)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		n && history.go(n);
		key();
	}));
});

var _Browser_pushUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.pushState({}, '', url);
		key();
	}));
});

var _Browser_replaceUrl = F2(function(key, url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function() {
		history.replaceState({}, '', url);
		key();
	}));
});



// GLOBAL EVENTS


var _Browser_fakeNode = { addEventListener: function() {}, removeEventListener: function() {} };
var _Browser_doc = typeof document !== 'undefined' ? document : _Browser_fakeNode;
var _Browser_window = typeof window !== 'undefined' ? window : _Browser_fakeNode;

var _Browser_on = F3(function(node, eventName, sendToSelf)
{
	return _Scheduler_spawn(_Scheduler_binding(function(callback)
	{
		function handler(event)	{ _Scheduler_rawSpawn(sendToSelf(event)); }
		node.addEventListener(eventName, handler, _VirtualDom_passiveSupported && { passive: true });
		return function() { node.removeEventListener(eventName, handler); };
	}));
});

var _Browser_decodeEvent = F2(function(decoder, event)
{
	var result = _Json_runHelp(decoder, event);
	return $elm$core$Result$isOk(result) ? $elm$core$Maybe$Just(result.a) : $elm$core$Maybe$Nothing;
});



// PAGE VISIBILITY


function _Browser_visibilityInfo()
{
	return (typeof _VirtualDom_doc.hidden !== 'undefined')
		? { cJ: 'hidden', cx: 'visibilitychange' }
		:
	(typeof _VirtualDom_doc.mozHidden !== 'undefined')
		? { cJ: 'mozHidden', cx: 'mozvisibilitychange' }
		:
	(typeof _VirtualDom_doc.msHidden !== 'undefined')
		? { cJ: 'msHidden', cx: 'msvisibilitychange' }
		:
	(typeof _VirtualDom_doc.webkitHidden !== 'undefined')
		? { cJ: 'webkitHidden', cx: 'webkitvisibilitychange' }
		: { cJ: 'hidden', cx: 'visibilitychange' };
}



// ANIMATION FRAMES


function _Browser_rAF()
{
	return _Scheduler_binding(function(callback)
	{
		var id = _Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(Date.now()));
		});

		return function() {
			_Browser_cancelAnimationFrame(id);
		};
	});
}


function _Browser_now()
{
	return _Scheduler_binding(function(callback)
	{
		callback(_Scheduler_succeed(Date.now()));
	});
}



// DOM STUFF


function _Browser_withNode(id, doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			var node = document.getElementById(id);
			callback(node
				? _Scheduler_succeed(doStuff(node))
				: _Scheduler_fail($elm$browser$Browser$Dom$NotFound(id))
			);
		});
	});
}


function _Browser_withWindow(doStuff)
{
	return _Scheduler_binding(function(callback)
	{
		_Browser_requestAnimationFrame(function() {
			callback(_Scheduler_succeed(doStuff()));
		});
	});
}


// FOCUS and BLUR


var _Browser_call = F2(function(functionName, id)
{
	return _Browser_withNode(id, function(node) {
		node[functionName]();
		return _Utils_Tuple0;
	});
});



// WINDOW VIEWPORT


function _Browser_getViewport()
{
	return {
		b6: _Browser_getScene(),
		cj: {
			cm: _Browser_window.pageXOffset,
			cn: _Browser_window.pageYOffset,
			cl: _Browser_doc.documentElement.clientWidth,
			bF: _Browser_doc.documentElement.clientHeight
		}
	};
}

function _Browser_getScene()
{
	var body = _Browser_doc.body;
	var elem = _Browser_doc.documentElement;
	return {
		cl: Math.max(body.scrollWidth, body.offsetWidth, elem.scrollWidth, elem.offsetWidth, elem.clientWidth),
		bF: Math.max(body.scrollHeight, body.offsetHeight, elem.scrollHeight, elem.offsetHeight, elem.clientHeight)
	};
}

var _Browser_setViewport = F2(function(x, y)
{
	return _Browser_withWindow(function()
	{
		_Browser_window.scroll(x, y);
		return _Utils_Tuple0;
	});
});



// ELEMENT VIEWPORT


function _Browser_getViewportOf(id)
{
	return _Browser_withNode(id, function(node)
	{
		return {
			b6: {
				cl: node.scrollWidth,
				bF: node.scrollHeight
			},
			cj: {
				cm: node.scrollLeft,
				cn: node.scrollTop,
				cl: node.clientWidth,
				bF: node.clientHeight
			}
		};
	});
}


var _Browser_setViewportOf = F3(function(id, x, y)
{
	return _Browser_withNode(id, function(node)
	{
		node.scrollLeft = x;
		node.scrollTop = y;
		return _Utils_Tuple0;
	});
});



// ELEMENT


function _Browser_getElement(id)
{
	return _Browser_withNode(id, function(node)
	{
		var rect = node.getBoundingClientRect();
		var x = _Browser_window.pageXOffset;
		var y = _Browser_window.pageYOffset;
		return {
			b6: _Browser_getScene(),
			cj: {
				cm: x,
				cn: y,
				cl: _Browser_doc.documentElement.clientWidth,
				bF: _Browser_doc.documentElement.clientHeight
			},
			cD: {
				cm: x + rect.left,
				cn: y + rect.top,
				cl: rect.width,
				bF: rect.height
			}
		};
	});
}



// LOAD and RELOAD


function _Browser_reload(skipCache)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		_VirtualDom_doc.location.reload(skipCache);
	}));
}

function _Browser_load(url)
{
	return A2($elm$core$Task$perform, $elm$core$Basics$never, _Scheduler_binding(function(callback)
	{
		try
		{
			_Browser_window.location = url;
		}
		catch(err)
		{
			// Only Firefox can throw a NS_ERROR_MALFORMED_URI exception here.
			// Other browsers reload the page, so let's be consistent about that.
			_VirtualDom_doc.location.reload(false);
		}
	}));
}


function _Url_percentEncode(string)
{
	return encodeURIComponent(string);
}

function _Url_percentDecode(string)
{
	try
	{
		return $elm$core$Maybe$Just(decodeURIComponent(string));
	}
	catch (e)
	{
		return $elm$core$Maybe$Nothing;
	}
}


// SEND REQUEST

var _Http_toTask = F3(function(router, toTask, request)
{
	return _Scheduler_binding(function(callback)
	{
		function done(response) {
			callback(toTask(request.W.a(response)));
		}

		var xhr = new XMLHttpRequest();
		xhr.addEventListener('error', function() { done($elm$http$Http$NetworkError_); });
		xhr.addEventListener('timeout', function() { done($elm$http$Http$Timeout_); });
		xhr.addEventListener('load', function() { done(_Http_toResponse(request.W.b, xhr)); });
		$elm$core$Maybe$isJust(request.ap) && _Http_track(router, xhr, request.ap.a);

		try {
			xhr.open(request.aj, request.ab, true);
		} catch (e) {
			return done($elm$http$Http$BadUrl_(request.ab));
		}

		_Http_configureRequest(xhr, request);

		request.z.a && xhr.setRequestHeader('Content-Type', request.z.a);
		xhr.send(request.z.b);

		return function() { xhr.c = true; xhr.abort(); };
	});
});


// CONFIGURE

function _Http_configureRequest(xhr, request)
{
	for (var headers = request.ah; headers.b; headers = headers.b) // WHILE_CONS
	{
		xhr.setRequestHeader(headers.a.a, headers.a.b);
	}
	xhr.timeout = request.an.a || 0;
	xhr.responseType = request.W.d;
	xhr.withCredentials = request.cq;
}


// RESPONSES

function _Http_toResponse(toBody, xhr)
{
	return A2(
		200 <= xhr.status && xhr.status < 300 ? $elm$http$Http$GoodStatus_ : $elm$http$Http$BadStatus_,
		_Http_toMetadata(xhr),
		toBody(xhr.response)
	);
}


// METADATA

function _Http_toMetadata(xhr)
{
	return {
		ab: xhr.responseURL,
		de: xhr.status,
		df: xhr.statusText,
		ah: _Http_parseHeaders(xhr.getAllResponseHeaders())
	};
}


// HEADERS

function _Http_parseHeaders(rawHeaders)
{
	if (!rawHeaders)
	{
		return $elm$core$Dict$empty;
	}

	var headers = $elm$core$Dict$empty;
	var headerPairs = rawHeaders.split('\r\n');
	for (var i = headerPairs.length; i--; )
	{
		var headerPair = headerPairs[i];
		var index = headerPair.indexOf(': ');
		if (index > 0)
		{
			var key = headerPair.substring(0, index);
			var value = headerPair.substring(index + 2);

			headers = A3($elm$core$Dict$update, key, function(oldValue) {
				return $elm$core$Maybe$Just($elm$core$Maybe$isJust(oldValue)
					? value + ', ' + oldValue.a
					: value
				);
			}, headers);
		}
	}
	return headers;
}


// EXPECT

var _Http_expect = F3(function(type, toBody, toValue)
{
	return {
		$: 0,
		d: type,
		b: toBody,
		a: toValue
	};
});

var _Http_mapExpect = F2(function(func, expect)
{
	return {
		$: 0,
		d: expect.d,
		b: expect.b,
		a: function(x) { return func(expect.a(x)); }
	};
});

function _Http_toDataView(arrayBuffer)
{
	return new DataView(arrayBuffer);
}


// BODY and PARTS

var _Http_emptyBody = { $: 0 };
var _Http_pair = F2(function(a, b) { return { $: 0, a: a, b: b }; });

function _Http_toFormData(parts)
{
	for (var formData = new FormData(); parts.b; parts = parts.b) // WHILE_CONS
	{
		var part = parts.a;
		formData.append(part.a, part.b);
	}
	return formData;
}

var _Http_bytesToBlob = F2(function(mime, bytes)
{
	return new Blob([bytes], { type: mime });
});


// PROGRESS

function _Http_track(router, xhr, tracker)
{
	// TODO check out lengthComputable on loadstart event

	xhr.upload.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Sending({
			dd: event.loaded,
			b9: event.total
		}))));
	});
	xhr.addEventListener('progress', function(event) {
		if (xhr.c) { return; }
		_Scheduler_rawSpawn(A2($elm$core$Platform$sendToSelf, router, _Utils_Tuple2(tracker, $elm$http$Http$Receiving({
			c7: event.loaded,
			b9: event.lengthComputable ? $elm$core$Maybe$Just(event.total) : $elm$core$Maybe$Nothing
		}))));
	});
}

// CREATE

var _Regex_never = /.^/;

var _Regex_fromStringWith = F2(function(options, string)
{
	var flags = 'g';
	if (options.cT) { flags += 'm'; }
	if (options.cw) { flags += 'i'; }

	try
	{
		return $elm$core$Maybe$Just(new RegExp(string, flags));
	}
	catch(error)
	{
		return $elm$core$Maybe$Nothing;
	}
});


// USE

var _Regex_contains = F2(function(re, string)
{
	return string.match(re) !== null;
});


var _Regex_findAtMost = F3(function(n, re, str)
{
	var out = [];
	var number = 0;
	var string = str;
	var lastIndex = re.lastIndex;
	var prevLastIndex = -1;
	var result;
	while (number++ < n && (result = re.exec(string)))
	{
		if (prevLastIndex == re.lastIndex) break;
		var i = result.length - 1;
		var subs = new Array(i);
		while (i > 0)
		{
			var submatch = result[i];
			subs[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		out.push(A4($elm$regex$Regex$Match, result[0], result.index, number, _List_fromArray(subs)));
		prevLastIndex = re.lastIndex;
	}
	re.lastIndex = lastIndex;
	return _List_fromArray(out);
});


var _Regex_replaceAtMost = F4(function(n, re, replacer, string)
{
	var count = 0;
	function jsReplacer(match)
	{
		if (count++ >= n)
		{
			return match;
		}
		var i = arguments.length - 3;
		var submatches = new Array(i);
		while (i > 0)
		{
			var submatch = arguments[i];
			submatches[--i] = submatch
				? $elm$core$Maybe$Just(submatch)
				: $elm$core$Maybe$Nothing;
		}
		return replacer(A4($elm$regex$Regex$Match, match, arguments[arguments.length - 2], count, _List_fromArray(submatches)));
	}
	return string.replace(re, jsReplacer);
});

var _Regex_splitAtMost = F3(function(n, re, str)
{
	var string = str;
	var out = [];
	var start = re.lastIndex;
	var restoreLastIndex = re.lastIndex;
	while (n--)
	{
		var result = re.exec(string);
		if (!result) break;
		out.push(string.slice(start, result.index));
		start = re.lastIndex;
	}
	out.push(string.slice(start));
	re.lastIndex = restoreLastIndex;
	return _List_fromArray(out);
});

var _Regex_infinity = Infinity;
var $author$project$Main$NewRoute = function (a) {
	return {$: 0, a: a};
};
var $author$project$Main$Visit = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$EQ = 1;
var $elm$core$Basics$GT = 2;
var $elm$core$Basics$LT = 0;
var $elm$core$List$cons = _List_cons;
var $elm$core$Dict$foldr = F3(
	function (func, acc, t) {
		foldr:
		while (true) {
			if (t.$ === -2) {
				return acc;
			} else {
				var key = t.b;
				var value = t.c;
				var left = t.d;
				var right = t.e;
				var $temp$func = func,
					$temp$acc = A3(
					func,
					key,
					value,
					A3($elm$core$Dict$foldr, func, acc, right)),
					$temp$t = left;
				func = $temp$func;
				acc = $temp$acc;
				t = $temp$t;
				continue foldr;
			}
		}
	});
var $elm$core$Dict$toList = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, list) {
				return A2(
					$elm$core$List$cons,
					_Utils_Tuple2(key, value),
					list);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Dict$keys = function (dict) {
	return A3(
		$elm$core$Dict$foldr,
		F3(
			function (key, value, keyList) {
				return A2($elm$core$List$cons, key, keyList);
			}),
		_List_Nil,
		dict);
};
var $elm$core$Set$toList = function (_v0) {
	var dict = _v0;
	return $elm$core$Dict$keys(dict);
};
var $elm$core$Elm$JsArray$foldr = _JsArray_foldr;
var $elm$core$Array$foldr = F3(
	function (func, baseCase, _v0) {
		var tree = _v0.c;
		var tail = _v0.d;
		var helper = F2(
			function (node, acc) {
				if (!node.$) {
					var subTree = node.a;
					return A3($elm$core$Elm$JsArray$foldr, helper, acc, subTree);
				} else {
					var values = node.a;
					return A3($elm$core$Elm$JsArray$foldr, func, acc, values);
				}
			});
		return A3(
			$elm$core$Elm$JsArray$foldr,
			helper,
			A3($elm$core$Elm$JsArray$foldr, func, baseCase, tail),
			tree);
	});
var $elm$core$Array$toList = function (array) {
	return A3($elm$core$Array$foldr, $elm$core$List$cons, _List_Nil, array);
};
var $elm$core$Result$Err = function (a) {
	return {$: 1, a: a};
};
var $elm$json$Json$Decode$Failure = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$json$Json$Decode$Field = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$json$Json$Decode$Index = F2(
	function (a, b) {
		return {$: 1, a: a, b: b};
	});
var $elm$core$Result$Ok = function (a) {
	return {$: 0, a: a};
};
var $elm$json$Json$Decode$OneOf = function (a) {
	return {$: 2, a: a};
};
var $elm$core$Basics$False = 1;
var $elm$core$Basics$add = _Basics_add;
var $elm$core$Maybe$Just = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Maybe$Nothing = {$: 1};
var $elm$core$String$all = _String_all;
var $elm$core$Basics$and = _Basics_and;
var $elm$core$Basics$append = _Utils_append;
var $elm$json$Json$Encode$encode = _Json_encode;
var $elm$core$String$fromInt = _String_fromNumber;
var $elm$core$String$join = F2(
	function (sep, chunks) {
		return A2(
			_String_join,
			sep,
			_List_toArray(chunks));
	});
var $elm$core$String$split = F2(
	function (sep, string) {
		return _List_fromArray(
			A2(_String_split, sep, string));
	});
var $elm$json$Json$Decode$indent = function (str) {
	return A2(
		$elm$core$String$join,
		'\n    ',
		A2($elm$core$String$split, '\n', str));
};
var $elm$core$List$foldl = F3(
	function (func, acc, list) {
		foldl:
		while (true) {
			if (!list.b) {
				return acc;
			} else {
				var x = list.a;
				var xs = list.b;
				var $temp$func = func,
					$temp$acc = A2(func, x, acc),
					$temp$list = xs;
				func = $temp$func;
				acc = $temp$acc;
				list = $temp$list;
				continue foldl;
			}
		}
	});
var $elm$core$List$length = function (xs) {
	return A3(
		$elm$core$List$foldl,
		F2(
			function (_v0, i) {
				return i + 1;
			}),
		0,
		xs);
};
var $elm$core$List$map2 = _List_map2;
var $elm$core$Basics$le = _Utils_le;
var $elm$core$Basics$sub = _Basics_sub;
var $elm$core$List$rangeHelp = F3(
	function (lo, hi, list) {
		rangeHelp:
		while (true) {
			if (_Utils_cmp(lo, hi) < 1) {
				var $temp$lo = lo,
					$temp$hi = hi - 1,
					$temp$list = A2($elm$core$List$cons, hi, list);
				lo = $temp$lo;
				hi = $temp$hi;
				list = $temp$list;
				continue rangeHelp;
			} else {
				return list;
			}
		}
	});
var $elm$core$List$range = F2(
	function (lo, hi) {
		return A3($elm$core$List$rangeHelp, lo, hi, _List_Nil);
	});
var $elm$core$List$indexedMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$map2,
			f,
			A2(
				$elm$core$List$range,
				0,
				$elm$core$List$length(xs) - 1),
			xs);
	});
var $elm$core$Char$toCode = _Char_toCode;
var $elm$core$Char$isLower = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (97 <= code) && (code <= 122);
};
var $elm$core$Char$isUpper = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 90) && (65 <= code);
};
var $elm$core$Basics$or = _Basics_or;
var $elm$core$Char$isAlpha = function (_char) {
	return $elm$core$Char$isLower(_char) || $elm$core$Char$isUpper(_char);
};
var $elm$core$Char$isDigit = function (_char) {
	var code = $elm$core$Char$toCode(_char);
	return (code <= 57) && (48 <= code);
};
var $elm$core$Char$isAlphaNum = function (_char) {
	return $elm$core$Char$isLower(_char) || ($elm$core$Char$isUpper(_char) || $elm$core$Char$isDigit(_char));
};
var $elm$core$List$reverse = function (list) {
	return A3($elm$core$List$foldl, $elm$core$List$cons, _List_Nil, list);
};
var $elm$core$String$uncons = _String_uncons;
var $elm$json$Json$Decode$errorOneOf = F2(
	function (i, error) {
		return '\n\n(' + ($elm$core$String$fromInt(i + 1) + (') ' + $elm$json$Json$Decode$indent(
			$elm$json$Json$Decode$errorToString(error))));
	});
var $elm$json$Json$Decode$errorToString = function (error) {
	return A2($elm$json$Json$Decode$errorToStringHelp, error, _List_Nil);
};
var $elm$json$Json$Decode$errorToStringHelp = F2(
	function (error, context) {
		errorToStringHelp:
		while (true) {
			switch (error.$) {
				case 0:
					var f = error.a;
					var err = error.b;
					var isSimple = function () {
						var _v1 = $elm$core$String$uncons(f);
						if (_v1.$ === 1) {
							return false;
						} else {
							var _v2 = _v1.a;
							var _char = _v2.a;
							var rest = _v2.b;
							return $elm$core$Char$isAlpha(_char) && A2($elm$core$String$all, $elm$core$Char$isAlphaNum, rest);
						}
					}();
					var fieldName = isSimple ? ('.' + f) : ('[\'' + (f + '\']'));
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, fieldName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 1:
					var i = error.a;
					var err = error.b;
					var indexName = '[' + ($elm$core$String$fromInt(i) + ']');
					var $temp$error = err,
						$temp$context = A2($elm$core$List$cons, indexName, context);
					error = $temp$error;
					context = $temp$context;
					continue errorToStringHelp;
				case 2:
					var errors = error.a;
					if (!errors.b) {
						return 'Ran into a Json.Decode.oneOf with no possibilities' + function () {
							if (!context.b) {
								return '!';
							} else {
								return ' at json' + A2(
									$elm$core$String$join,
									'',
									$elm$core$List$reverse(context));
							}
						}();
					} else {
						if (!errors.b.b) {
							var err = errors.a;
							var $temp$error = err,
								$temp$context = context;
							error = $temp$error;
							context = $temp$context;
							continue errorToStringHelp;
						} else {
							var starter = function () {
								if (!context.b) {
									return 'Json.Decode.oneOf';
								} else {
									return 'The Json.Decode.oneOf at json' + A2(
										$elm$core$String$join,
										'',
										$elm$core$List$reverse(context));
								}
							}();
							var introduction = starter + (' failed in the following ' + ($elm$core$String$fromInt(
								$elm$core$List$length(errors)) + ' ways:'));
							return A2(
								$elm$core$String$join,
								'\n\n',
								A2(
									$elm$core$List$cons,
									introduction,
									A2($elm$core$List$indexedMap, $elm$json$Json$Decode$errorOneOf, errors)));
						}
					}
				default:
					var msg = error.a;
					var json = error.b;
					var introduction = function () {
						if (!context.b) {
							return 'Problem with the given value:\n\n';
						} else {
							return 'Problem with the value at json' + (A2(
								$elm$core$String$join,
								'',
								$elm$core$List$reverse(context)) + ':\n\n    ');
						}
					}();
					return introduction + ($elm$json$Json$Decode$indent(
						A2($elm$json$Json$Encode$encode, 4, json)) + ('\n\n' + msg));
			}
		}
	});
var $elm$core$Array$branchFactor = 32;
var $elm$core$Array$Array_elm_builtin = F4(
	function (a, b, c, d) {
		return {$: 0, a: a, b: b, c: c, d: d};
	});
var $elm$core$Elm$JsArray$empty = _JsArray_empty;
var $elm$core$Basics$ceiling = _Basics_ceiling;
var $elm$core$Basics$fdiv = _Basics_fdiv;
var $elm$core$Basics$logBase = F2(
	function (base, number) {
		return _Basics_log(number) / _Basics_log(base);
	});
var $elm$core$Basics$toFloat = _Basics_toFloat;
var $elm$core$Array$shiftStep = $elm$core$Basics$ceiling(
	A2($elm$core$Basics$logBase, 2, $elm$core$Array$branchFactor));
var $elm$core$Array$empty = A4($elm$core$Array$Array_elm_builtin, 0, $elm$core$Array$shiftStep, $elm$core$Elm$JsArray$empty, $elm$core$Elm$JsArray$empty);
var $elm$core$Elm$JsArray$initialize = _JsArray_initialize;
var $elm$core$Array$Leaf = function (a) {
	return {$: 1, a: a};
};
var $elm$core$Basics$apL = F2(
	function (f, x) {
		return f(x);
	});
var $elm$core$Basics$apR = F2(
	function (x, f) {
		return f(x);
	});
var $elm$core$Basics$eq = _Utils_equal;
var $elm$core$Basics$floor = _Basics_floor;
var $elm$core$Elm$JsArray$length = _JsArray_length;
var $elm$core$Basics$gt = _Utils_gt;
var $elm$core$Basics$max = F2(
	function (x, y) {
		return (_Utils_cmp(x, y) > 0) ? x : y;
	});
var $elm$core$Basics$mul = _Basics_mul;
var $elm$core$Array$SubTree = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Elm$JsArray$initializeFromList = _JsArray_initializeFromList;
var $elm$core$Array$compressNodes = F2(
	function (nodes, acc) {
		compressNodes:
		while (true) {
			var _v0 = A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodes);
			var node = _v0.a;
			var remainingNodes = _v0.b;
			var newAcc = A2(
				$elm$core$List$cons,
				$elm$core$Array$SubTree(node),
				acc);
			if (!remainingNodes.b) {
				return $elm$core$List$reverse(newAcc);
			} else {
				var $temp$nodes = remainingNodes,
					$temp$acc = newAcc;
				nodes = $temp$nodes;
				acc = $temp$acc;
				continue compressNodes;
			}
		}
	});
var $elm$core$Tuple$first = function (_v0) {
	var x = _v0.a;
	return x;
};
var $elm$core$Array$treeFromBuilder = F2(
	function (nodeList, nodeListSize) {
		treeFromBuilder:
		while (true) {
			var newNodeSize = $elm$core$Basics$ceiling(nodeListSize / $elm$core$Array$branchFactor);
			if (newNodeSize === 1) {
				return A2($elm$core$Elm$JsArray$initializeFromList, $elm$core$Array$branchFactor, nodeList).a;
			} else {
				var $temp$nodeList = A2($elm$core$Array$compressNodes, nodeList, _List_Nil),
					$temp$nodeListSize = newNodeSize;
				nodeList = $temp$nodeList;
				nodeListSize = $temp$nodeListSize;
				continue treeFromBuilder;
			}
		}
	});
var $elm$core$Array$builderToArray = F2(
	function (reverseNodeList, builder) {
		if (!builder.p) {
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.r),
				$elm$core$Array$shiftStep,
				$elm$core$Elm$JsArray$empty,
				builder.r);
		} else {
			var treeLen = builder.p * $elm$core$Array$branchFactor;
			var depth = $elm$core$Basics$floor(
				A2($elm$core$Basics$logBase, $elm$core$Array$branchFactor, treeLen - 1));
			var correctNodeList = reverseNodeList ? $elm$core$List$reverse(builder.s) : builder.s;
			var tree = A2($elm$core$Array$treeFromBuilder, correctNodeList, builder.p);
			return A4(
				$elm$core$Array$Array_elm_builtin,
				$elm$core$Elm$JsArray$length(builder.r) + treeLen,
				A2($elm$core$Basics$max, 5, depth * $elm$core$Array$shiftStep),
				tree,
				builder.r);
		}
	});
var $elm$core$Basics$idiv = _Basics_idiv;
var $elm$core$Basics$lt = _Utils_lt;
var $elm$core$Array$initializeHelp = F5(
	function (fn, fromIndex, len, nodeList, tail) {
		initializeHelp:
		while (true) {
			if (fromIndex < 0) {
				return A2(
					$elm$core$Array$builderToArray,
					false,
					{s: nodeList, p: (len / $elm$core$Array$branchFactor) | 0, r: tail});
			} else {
				var leaf = $elm$core$Array$Leaf(
					A3($elm$core$Elm$JsArray$initialize, $elm$core$Array$branchFactor, fromIndex, fn));
				var $temp$fn = fn,
					$temp$fromIndex = fromIndex - $elm$core$Array$branchFactor,
					$temp$len = len,
					$temp$nodeList = A2($elm$core$List$cons, leaf, nodeList),
					$temp$tail = tail;
				fn = $temp$fn;
				fromIndex = $temp$fromIndex;
				len = $temp$len;
				nodeList = $temp$nodeList;
				tail = $temp$tail;
				continue initializeHelp;
			}
		}
	});
var $elm$core$Basics$remainderBy = _Basics_remainderBy;
var $elm$core$Array$initialize = F2(
	function (len, fn) {
		if (len <= 0) {
			return $elm$core$Array$empty;
		} else {
			var tailLen = len % $elm$core$Array$branchFactor;
			var tail = A3($elm$core$Elm$JsArray$initialize, tailLen, len - tailLen, fn);
			var initialFromIndex = (len - tailLen) - $elm$core$Array$branchFactor;
			return A5($elm$core$Array$initializeHelp, fn, initialFromIndex, len, _List_Nil, tail);
		}
	});
var $elm$core$Basics$True = 0;
var $elm$core$Result$isOk = function (result) {
	if (!result.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$json$Json$Decode$map = _Json_map1;
var $elm$json$Json$Decode$map2 = _Json_map2;
var $elm$json$Json$Decode$succeed = _Json_succeed;
var $elm$virtual_dom$VirtualDom$toHandlerInt = function (handler) {
	switch (handler.$) {
		case 0:
			return 0;
		case 1:
			return 1;
		case 2:
			return 2;
		default:
			return 3;
	}
};
var $elm$browser$Browser$External = function (a) {
	return {$: 1, a: a};
};
var $elm$browser$Browser$Internal = function (a) {
	return {$: 0, a: a};
};
var $elm$core$Basics$identity = function (x) {
	return x;
};
var $elm$browser$Browser$Dom$NotFound = $elm$core$Basics$identity;
var $elm$url$Url$Http = 0;
var $elm$url$Url$Https = 1;
var $elm$url$Url$Url = F6(
	function (protocol, host, port_, path, query, fragment) {
		return {bB: fragment, bH: host, c6: path, bW: port_, b_: protocol, b$: query};
	});
var $elm$core$String$contains = _String_contains;
var $elm$core$String$length = _String_length;
var $elm$core$String$slice = _String_slice;
var $elm$core$String$dropLeft = F2(
	function (n, string) {
		return (n < 1) ? string : A3(
			$elm$core$String$slice,
			n,
			$elm$core$String$length(string),
			string);
	});
var $elm$core$String$indexes = _String_indexes;
var $elm$core$String$isEmpty = function (string) {
	return string === '';
};
var $elm$core$String$left = F2(
	function (n, string) {
		return (n < 1) ? '' : A3($elm$core$String$slice, 0, n, string);
	});
var $elm$core$String$toInt = _String_toInt;
var $elm$url$Url$chompBeforePath = F5(
	function (protocol, path, params, frag, str) {
		if ($elm$core$String$isEmpty(str) || A2($elm$core$String$contains, '@', str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, ':', str);
			if (!_v0.b) {
				return $elm$core$Maybe$Just(
					A6($elm$url$Url$Url, protocol, str, $elm$core$Maybe$Nothing, path, params, frag));
			} else {
				if (!_v0.b.b) {
					var i = _v0.a;
					var _v1 = $elm$core$String$toInt(
						A2($elm$core$String$dropLeft, i + 1, str));
					if (_v1.$ === 1) {
						return $elm$core$Maybe$Nothing;
					} else {
						var port_ = _v1;
						return $elm$core$Maybe$Just(
							A6(
								$elm$url$Url$Url,
								protocol,
								A2($elm$core$String$left, i, str),
								port_,
								path,
								params,
								frag));
					}
				} else {
					return $elm$core$Maybe$Nothing;
				}
			}
		}
	});
var $elm$url$Url$chompBeforeQuery = F4(
	function (protocol, params, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '/', str);
			if (!_v0.b) {
				return A5($elm$url$Url$chompBeforePath, protocol, '/', params, frag, str);
			} else {
				var i = _v0.a;
				return A5(
					$elm$url$Url$chompBeforePath,
					protocol,
					A2($elm$core$String$dropLeft, i, str),
					params,
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompBeforeFragment = F3(
	function (protocol, frag, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '?', str);
			if (!_v0.b) {
				return A4($elm$url$Url$chompBeforeQuery, protocol, $elm$core$Maybe$Nothing, frag, str);
			} else {
				var i = _v0.a;
				return A4(
					$elm$url$Url$chompBeforeQuery,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					frag,
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$url$Url$chompAfterProtocol = F2(
	function (protocol, str) {
		if ($elm$core$String$isEmpty(str)) {
			return $elm$core$Maybe$Nothing;
		} else {
			var _v0 = A2($elm$core$String$indexes, '#', str);
			if (!_v0.b) {
				return A3($elm$url$Url$chompBeforeFragment, protocol, $elm$core$Maybe$Nothing, str);
			} else {
				var i = _v0.a;
				return A3(
					$elm$url$Url$chompBeforeFragment,
					protocol,
					$elm$core$Maybe$Just(
						A2($elm$core$String$dropLeft, i + 1, str)),
					A2($elm$core$String$left, i, str));
			}
		}
	});
var $elm$core$String$startsWith = _String_startsWith;
var $elm$url$Url$fromString = function (str) {
	return A2($elm$core$String$startsWith, 'http://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		0,
		A2($elm$core$String$dropLeft, 7, str)) : (A2($elm$core$String$startsWith, 'https://', str) ? A2(
		$elm$url$Url$chompAfterProtocol,
		1,
		A2($elm$core$String$dropLeft, 8, str)) : $elm$core$Maybe$Nothing);
};
var $elm$core$Basics$never = function (_v0) {
	never:
	while (true) {
		var nvr = _v0;
		var $temp$_v0 = nvr;
		_v0 = $temp$_v0;
		continue never;
	}
};
var $elm$core$Task$Perform = $elm$core$Basics$identity;
var $elm$core$Task$succeed = _Scheduler_succeed;
var $elm$core$Task$init = $elm$core$Task$succeed(0);
var $elm$core$List$foldrHelper = F4(
	function (fn, acc, ctr, ls) {
		if (!ls.b) {
			return acc;
		} else {
			var a = ls.a;
			var r1 = ls.b;
			if (!r1.b) {
				return A2(fn, a, acc);
			} else {
				var b = r1.a;
				var r2 = r1.b;
				if (!r2.b) {
					return A2(
						fn,
						a,
						A2(fn, b, acc));
				} else {
					var c = r2.a;
					var r3 = r2.b;
					if (!r3.b) {
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(fn, c, acc)));
					} else {
						var d = r3.a;
						var r4 = r3.b;
						var res = (ctr > 500) ? A3(
							$elm$core$List$foldl,
							fn,
							acc,
							$elm$core$List$reverse(r4)) : A4($elm$core$List$foldrHelper, fn, acc, ctr + 1, r4);
						return A2(
							fn,
							a,
							A2(
								fn,
								b,
								A2(
									fn,
									c,
									A2(fn, d, res))));
					}
				}
			}
		}
	});
var $elm$core$List$foldr = F3(
	function (fn, acc, ls) {
		return A4($elm$core$List$foldrHelper, fn, acc, 0, ls);
	});
var $elm$core$List$map = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			F2(
				function (x, acc) {
					return A2(
						$elm$core$List$cons,
						f(x),
						acc);
				}),
			_List_Nil,
			xs);
	});
var $elm$core$Task$andThen = _Scheduler_andThen;
var $elm$core$Task$map = F2(
	function (func, taskA) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return $elm$core$Task$succeed(
					func(a));
			},
			taskA);
	});
var $elm$core$Task$map2 = F3(
	function (func, taskA, taskB) {
		return A2(
			$elm$core$Task$andThen,
			function (a) {
				return A2(
					$elm$core$Task$andThen,
					function (b) {
						return $elm$core$Task$succeed(
							A2(func, a, b));
					},
					taskB);
			},
			taskA);
	});
var $elm$core$Task$sequence = function (tasks) {
	return A3(
		$elm$core$List$foldr,
		$elm$core$Task$map2($elm$core$List$cons),
		$elm$core$Task$succeed(_List_Nil),
		tasks);
};
var $elm$core$Platform$sendToApp = _Platform_sendToApp;
var $elm$core$Task$spawnCmd = F2(
	function (router, _v0) {
		var task = _v0;
		return _Scheduler_spawn(
			A2(
				$elm$core$Task$andThen,
				$elm$core$Platform$sendToApp(router),
				task));
	});
var $elm$core$Task$onEffects = F3(
	function (router, commands, state) {
		return A2(
			$elm$core$Task$map,
			function (_v0) {
				return 0;
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$map,
					$elm$core$Task$spawnCmd(router),
					commands)));
	});
var $elm$core$Task$onSelfMsg = F3(
	function (_v0, _v1, _v2) {
		return $elm$core$Task$succeed(0);
	});
var $elm$core$Task$cmdMap = F2(
	function (tagger, _v0) {
		var task = _v0;
		return A2($elm$core$Task$map, tagger, task);
	});
_Platform_effectManagers['Task'] = _Platform_createManager($elm$core$Task$init, $elm$core$Task$onEffects, $elm$core$Task$onSelfMsg, $elm$core$Task$cmdMap);
var $elm$core$Task$command = _Platform_leaf('Task');
var $elm$core$Task$perform = F2(
	function (toMessage, task) {
		return $elm$core$Task$command(
			A2($elm$core$Task$map, toMessage, task));
	});
var $elm$browser$Browser$application = _Browser_application;
var $elm$core$Basics$composeR = F3(
	function (f, g, x) {
		return g(
			f(x));
	});
var $author$project$Main$NotFound = {$: 7};
var $author$project$Main$defaultAuthor = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just(''),
	j: ''
};
var $author$project$Main$defaultArticle = {
	h: $author$project$Main$defaultAuthor,
	z: '',
	ae: '',
	bu: '',
	aJ: false,
	a5: 0,
	J: '',
	cf: _List_fromArray(
		['']),
	bi: '',
	a2: ''
};
var $author$project$Main$defaultComment = {h: $author$project$Main$defaultAuthor, z: 'With supporting text below as a natural lead-in to additional content.', ae: 'Dec 29th', a7: 0, a2: ''};
var $author$project$Main$defaultProfile = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just(''),
	j: ''
};
var $author$project$Main$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Main$initialModel = F2(
	function (navigationKey, url) {
		return {
			d: $author$project$Main$defaultArticle,
			E: $elm$core$Maybe$Nothing,
			as: $elm$core$Maybe$Just(
				_List_fromArray(
					[$author$project$Main$defaultComment])),
			m: '',
			ax: false,
			a9: navigationKey,
			e: $author$project$Main$NotFound,
			x: $author$project$Main$defaultProfile,
			am: '',
			ab: url,
			D: $author$project$Main$defaultUser
		};
	});
var $elm$url$Url$Parser$State = F5(
	function (visited, unvisited, params, frag, value) {
		return {ag: frag, ak: params, aa: unvisited, U: value, ar: visited};
	});
var $elm$url$Url$Parser$getFirstMatch = function (states) {
	getFirstMatch:
	while (true) {
		if (!states.b) {
			return $elm$core$Maybe$Nothing;
		} else {
			var state = states.a;
			var rest = states.b;
			var _v1 = state.aa;
			if (!_v1.b) {
				return $elm$core$Maybe$Just(state.U);
			} else {
				if ((_v1.a === '') && (!_v1.b.b)) {
					return $elm$core$Maybe$Just(state.U);
				} else {
					var $temp$states = rest;
					states = $temp$states;
					continue getFirstMatch;
				}
			}
		}
	}
};
var $elm$url$Url$Parser$removeFinalEmpty = function (segments) {
	if (!segments.b) {
		return _List_Nil;
	} else {
		if ((segments.a === '') && (!segments.b.b)) {
			return _List_Nil;
		} else {
			var segment = segments.a;
			var rest = segments.b;
			return A2(
				$elm$core$List$cons,
				segment,
				$elm$url$Url$Parser$removeFinalEmpty(rest));
		}
	}
};
var $elm$url$Url$Parser$preparePath = function (path) {
	var _v0 = A2($elm$core$String$split, '/', path);
	if (_v0.b && (_v0.a === '')) {
		var segments = _v0.b;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	} else {
		var segments = _v0;
		return $elm$url$Url$Parser$removeFinalEmpty(segments);
	}
};
var $elm$url$Url$Parser$addToParametersHelp = F2(
	function (value, maybeList) {
		if (maybeList.$ === 1) {
			return $elm$core$Maybe$Just(
				_List_fromArray(
					[value]));
		} else {
			var list = maybeList.a;
			return $elm$core$Maybe$Just(
				A2($elm$core$List$cons, value, list));
		}
	});
var $elm$url$Url$percentDecode = _Url_percentDecode;
var $elm$core$Basics$compare = _Utils_compare;
var $elm$core$Dict$get = F2(
	function (targetKey, dict) {
		get:
		while (true) {
			if (dict.$ === -2) {
				return $elm$core$Maybe$Nothing;
			} else {
				var key = dict.b;
				var value = dict.c;
				var left = dict.d;
				var right = dict.e;
				var _v1 = A2($elm$core$Basics$compare, targetKey, key);
				switch (_v1) {
					case 0:
						var $temp$targetKey = targetKey,
							$temp$dict = left;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
					case 1:
						return $elm$core$Maybe$Just(value);
					default:
						var $temp$targetKey = targetKey,
							$temp$dict = right;
						targetKey = $temp$targetKey;
						dict = $temp$dict;
						continue get;
				}
			}
		}
	});
var $elm$core$Dict$Black = 1;
var $elm$core$Dict$RBNode_elm_builtin = F5(
	function (a, b, c, d, e) {
		return {$: -1, a: a, b: b, c: c, d: d, e: e};
	});
var $elm$core$Dict$RBEmpty_elm_builtin = {$: -2};
var $elm$core$Dict$Red = 0;
var $elm$core$Dict$balance = F5(
	function (color, key, value, left, right) {
		if ((right.$ === -1) && (!right.a)) {
			var _v1 = right.a;
			var rK = right.b;
			var rV = right.c;
			var rLeft = right.d;
			var rRight = right.e;
			if ((left.$ === -1) && (!left.a)) {
				var _v3 = left.a;
				var lK = left.b;
				var lV = left.c;
				var lLeft = left.d;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					key,
					value,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					rK,
					rV,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, left, rLeft),
					rRight);
			}
		} else {
			if ((((left.$ === -1) && (!left.a)) && (left.d.$ === -1)) && (!left.d.a)) {
				var _v5 = left.a;
				var lK = left.b;
				var lV = left.c;
				var _v6 = left.d;
				var _v7 = _v6.a;
				var llK = _v6.b;
				var llV = _v6.c;
				var llLeft = _v6.d;
				var llRight = _v6.e;
				var lRight = left.e;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					0,
					lK,
					lV,
					A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 1, key, value, lRight, right));
			} else {
				return A5($elm$core$Dict$RBNode_elm_builtin, color, key, value, left, right);
			}
		}
	});
var $elm$core$Dict$insertHelp = F3(
	function (key, value, dict) {
		if (dict.$ === -2) {
			return A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, $elm$core$Dict$RBEmpty_elm_builtin, $elm$core$Dict$RBEmpty_elm_builtin);
		} else {
			var nColor = dict.a;
			var nKey = dict.b;
			var nValue = dict.c;
			var nLeft = dict.d;
			var nRight = dict.e;
			var _v1 = A2($elm$core$Basics$compare, key, nKey);
			switch (_v1) {
				case 0:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						A3($elm$core$Dict$insertHelp, key, value, nLeft),
						nRight);
				case 1:
					return A5($elm$core$Dict$RBNode_elm_builtin, nColor, nKey, value, nLeft, nRight);
				default:
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						nLeft,
						A3($elm$core$Dict$insertHelp, key, value, nRight));
			}
		}
	});
var $elm$core$Dict$insert = F3(
	function (key, value, dict) {
		var _v0 = A3($elm$core$Dict$insertHelp, key, value, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$getMin = function (dict) {
	getMin:
	while (true) {
		if ((dict.$ === -1) && (dict.d.$ === -1)) {
			var left = dict.d;
			var $temp$dict = left;
			dict = $temp$dict;
			continue getMin;
		} else {
			return dict;
		}
	}
};
var $elm$core$Dict$moveRedLeft = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.e.d.$ === -1) && (!dict.e.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var lLeft = _v1.d;
			var lRight = _v1.e;
			var _v2 = dict.e;
			var rClr = _v2.a;
			var rK = _v2.b;
			var rV = _v2.c;
			var rLeft = _v2.d;
			var _v3 = rLeft.a;
			var rlK = rLeft.b;
			var rlV = rLeft.c;
			var rlL = rLeft.d;
			var rlR = rLeft.e;
			var rRight = _v2.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				rlK,
				rlV,
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					rlL),
				A5($elm$core$Dict$RBNode_elm_builtin, 1, rK, rV, rlR, rRight));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v4 = dict.d;
			var lClr = _v4.a;
			var lK = _v4.b;
			var lV = _v4.c;
			var lLeft = _v4.d;
			var lRight = _v4.e;
			var _v5 = dict.e;
			var rClr = _v5.a;
			var rK = _v5.b;
			var rV = _v5.c;
			var rLeft = _v5.d;
			var rRight = _v5.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$moveRedRight = function (dict) {
	if (((dict.$ === -1) && (dict.d.$ === -1)) && (dict.e.$ === -1)) {
		if ((dict.d.d.$ === -1) && (!dict.d.d.a)) {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v1 = dict.d;
			var lClr = _v1.a;
			var lK = _v1.b;
			var lV = _v1.c;
			var _v2 = _v1.d;
			var _v3 = _v2.a;
			var llK = _v2.b;
			var llV = _v2.c;
			var llLeft = _v2.d;
			var llRight = _v2.e;
			var lRight = _v1.e;
			var _v4 = dict.e;
			var rClr = _v4.a;
			var rK = _v4.b;
			var rV = _v4.c;
			var rLeft = _v4.d;
			var rRight = _v4.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				0,
				lK,
				lV,
				A5($elm$core$Dict$RBNode_elm_builtin, 1, llK, llV, llLeft, llRight),
				A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					lRight,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight)));
		} else {
			var clr = dict.a;
			var k = dict.b;
			var v = dict.c;
			var _v5 = dict.d;
			var lClr = _v5.a;
			var lK = _v5.b;
			var lV = _v5.c;
			var lLeft = _v5.d;
			var lRight = _v5.e;
			var _v6 = dict.e;
			var rClr = _v6.a;
			var rK = _v6.b;
			var rV = _v6.c;
			var rLeft = _v6.d;
			var rRight = _v6.e;
			if (clr === 1) {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			} else {
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					1,
					k,
					v,
					A5($elm$core$Dict$RBNode_elm_builtin, 0, lK, lV, lLeft, lRight),
					A5($elm$core$Dict$RBNode_elm_builtin, 0, rK, rV, rLeft, rRight));
			}
		}
	} else {
		return dict;
	}
};
var $elm$core$Dict$removeHelpPrepEQGT = F7(
	function (targetKey, dict, color, key, value, left, right) {
		if ((left.$ === -1) && (!left.a)) {
			var _v1 = left.a;
			var lK = left.b;
			var lV = left.c;
			var lLeft = left.d;
			var lRight = left.e;
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				lK,
				lV,
				lLeft,
				A5($elm$core$Dict$RBNode_elm_builtin, 0, key, value, lRight, right));
		} else {
			_v2$2:
			while (true) {
				if ((right.$ === -1) && (right.a === 1)) {
					if (right.d.$ === -1) {
						if (right.d.a === 1) {
							var _v3 = right.a;
							var _v4 = right.d;
							var _v5 = _v4.a;
							return $elm$core$Dict$moveRedRight(dict);
						} else {
							break _v2$2;
						}
					} else {
						var _v6 = right.a;
						var _v7 = right.d;
						return $elm$core$Dict$moveRedRight(dict);
					}
				} else {
					break _v2$2;
				}
			}
			return dict;
		}
	});
var $elm$core$Dict$removeMin = function (dict) {
	if ((dict.$ === -1) && (dict.d.$ === -1)) {
		var color = dict.a;
		var key = dict.b;
		var value = dict.c;
		var left = dict.d;
		var lColor = left.a;
		var lLeft = left.d;
		var right = dict.e;
		if (lColor === 1) {
			if ((lLeft.$ === -1) && (!lLeft.a)) {
				var _v3 = lLeft.a;
				return A5(
					$elm$core$Dict$RBNode_elm_builtin,
					color,
					key,
					value,
					$elm$core$Dict$removeMin(left),
					right);
			} else {
				var _v4 = $elm$core$Dict$moveRedLeft(dict);
				if (_v4.$ === -1) {
					var nColor = _v4.a;
					var nKey = _v4.b;
					var nValue = _v4.c;
					var nLeft = _v4.d;
					var nRight = _v4.e;
					return A5(
						$elm$core$Dict$balance,
						nColor,
						nKey,
						nValue,
						$elm$core$Dict$removeMin(nLeft),
						nRight);
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			}
		} else {
			return A5(
				$elm$core$Dict$RBNode_elm_builtin,
				color,
				key,
				value,
				$elm$core$Dict$removeMin(left),
				right);
		}
	} else {
		return $elm$core$Dict$RBEmpty_elm_builtin;
	}
};
var $elm$core$Dict$removeHelp = F2(
	function (targetKey, dict) {
		if (dict.$ === -2) {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		} else {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_cmp(targetKey, key) < 0) {
				if ((left.$ === -1) && (left.a === 1)) {
					var _v4 = left.a;
					var lLeft = left.d;
					if ((lLeft.$ === -1) && (!lLeft.a)) {
						var _v6 = lLeft.a;
						return A5(
							$elm$core$Dict$RBNode_elm_builtin,
							color,
							key,
							value,
							A2($elm$core$Dict$removeHelp, targetKey, left),
							right);
					} else {
						var _v7 = $elm$core$Dict$moveRedLeft(dict);
						if (_v7.$ === -1) {
							var nColor = _v7.a;
							var nKey = _v7.b;
							var nValue = _v7.c;
							var nLeft = _v7.d;
							var nRight = _v7.e;
							return A5(
								$elm$core$Dict$balance,
								nColor,
								nKey,
								nValue,
								A2($elm$core$Dict$removeHelp, targetKey, nLeft),
								nRight);
						} else {
							return $elm$core$Dict$RBEmpty_elm_builtin;
						}
					}
				} else {
					return A5(
						$elm$core$Dict$RBNode_elm_builtin,
						color,
						key,
						value,
						A2($elm$core$Dict$removeHelp, targetKey, left),
						right);
				}
			} else {
				return A2(
					$elm$core$Dict$removeHelpEQGT,
					targetKey,
					A7($elm$core$Dict$removeHelpPrepEQGT, targetKey, dict, color, key, value, left, right));
			}
		}
	});
var $elm$core$Dict$removeHelpEQGT = F2(
	function (targetKey, dict) {
		if (dict.$ === -1) {
			var color = dict.a;
			var key = dict.b;
			var value = dict.c;
			var left = dict.d;
			var right = dict.e;
			if (_Utils_eq(targetKey, key)) {
				var _v1 = $elm$core$Dict$getMin(right);
				if (_v1.$ === -1) {
					var minKey = _v1.b;
					var minValue = _v1.c;
					return A5(
						$elm$core$Dict$balance,
						color,
						minKey,
						minValue,
						left,
						$elm$core$Dict$removeMin(right));
				} else {
					return $elm$core$Dict$RBEmpty_elm_builtin;
				}
			} else {
				return A5(
					$elm$core$Dict$balance,
					color,
					key,
					value,
					left,
					A2($elm$core$Dict$removeHelp, targetKey, right));
			}
		} else {
			return $elm$core$Dict$RBEmpty_elm_builtin;
		}
	});
var $elm$core$Dict$remove = F2(
	function (key, dict) {
		var _v0 = A2($elm$core$Dict$removeHelp, key, dict);
		if ((_v0.$ === -1) && (!_v0.a)) {
			var _v1 = _v0.a;
			var k = _v0.b;
			var v = _v0.c;
			var l = _v0.d;
			var r = _v0.e;
			return A5($elm$core$Dict$RBNode_elm_builtin, 1, k, v, l, r);
		} else {
			var x = _v0;
			return x;
		}
	});
var $elm$core$Dict$update = F3(
	function (targetKey, alter, dictionary) {
		var _v0 = alter(
			A2($elm$core$Dict$get, targetKey, dictionary));
		if (!_v0.$) {
			var value = _v0.a;
			return A3($elm$core$Dict$insert, targetKey, value, dictionary);
		} else {
			return A2($elm$core$Dict$remove, targetKey, dictionary);
		}
	});
var $elm$url$Url$Parser$addParam = F2(
	function (segment, dict) {
		var _v0 = A2($elm$core$String$split, '=', segment);
		if ((_v0.b && _v0.b.b) && (!_v0.b.b.b)) {
			var rawKey = _v0.a;
			var _v1 = _v0.b;
			var rawValue = _v1.a;
			var _v2 = $elm$url$Url$percentDecode(rawKey);
			if (_v2.$ === 1) {
				return dict;
			} else {
				var key = _v2.a;
				var _v3 = $elm$url$Url$percentDecode(rawValue);
				if (_v3.$ === 1) {
					return dict;
				} else {
					var value = _v3.a;
					return A3(
						$elm$core$Dict$update,
						key,
						$elm$url$Url$Parser$addToParametersHelp(value),
						dict);
				}
			}
		} else {
			return dict;
		}
	});
var $elm$core$Dict$empty = $elm$core$Dict$RBEmpty_elm_builtin;
var $elm$url$Url$Parser$prepareQuery = function (maybeQuery) {
	if (maybeQuery.$ === 1) {
		return $elm$core$Dict$empty;
	} else {
		var qry = maybeQuery.a;
		return A3(
			$elm$core$List$foldr,
			$elm$url$Url$Parser$addParam,
			$elm$core$Dict$empty,
			A2($elm$core$String$split, '&', qry));
	}
};
var $elm$url$Url$Parser$parse = F2(
	function (_v0, url) {
		var parser = _v0;
		return $elm$url$Url$Parser$getFirstMatch(
			parser(
				A5(
					$elm$url$Url$Parser$State,
					_List_Nil,
					$elm$url$Url$Parser$preparePath(url.c6),
					$elm$url$Url$Parser$prepareQuery(url.b$),
					url.bB,
					$elm$core$Basics$identity)));
	});
var $author$project$Routes$Article = function (a) {
	return {$: 5, a: a};
};
var $author$project$Routes$Auth = {$: 1};
var $author$project$Routes$Editor = function (a) {
	return {$: 3, a: a};
};
var $author$project$Routes$Favorited = 0;
var $author$project$Routes$Home = {$: 0};
var $author$project$Routes$Login = {$: 4};
var $author$project$Routes$NewEditor = {$: 2};
var $author$project$Routes$Profile = F2(
	function (a, b) {
		return {$: 6, a: a, b: b};
	});
var $author$project$Routes$Settings = {$: 7};
var $author$project$Routes$WholeProfile = 1;
var $elm$url$Url$Parser$Parser = $elm$core$Basics$identity;
var $elm$url$Url$Parser$mapState = F2(
	function (func, _v0) {
		var visited = _v0.ar;
		var unvisited = _v0.aa;
		var params = _v0.ak;
		var frag = _v0.ag;
		var value = _v0.U;
		return A5(
			$elm$url$Url$Parser$State,
			visited,
			unvisited,
			params,
			frag,
			func(value));
	});
var $elm$url$Url$Parser$map = F2(
	function (subValue, _v0) {
		var parseArg = _v0;
		return function (_v1) {
			var visited = _v1.ar;
			var unvisited = _v1.aa;
			var params = _v1.ak;
			var frag = _v1.ag;
			var value = _v1.U;
			return A2(
				$elm$core$List$map,
				$elm$url$Url$Parser$mapState(value),
				parseArg(
					A5($elm$url$Url$Parser$State, visited, unvisited, params, frag, subValue)));
		};
	});
var $elm$core$List$append = F2(
	function (xs, ys) {
		if (!ys.b) {
			return xs;
		} else {
			return A3($elm$core$List$foldr, $elm$core$List$cons, ys, xs);
		}
	});
var $elm$core$List$concat = function (lists) {
	return A3($elm$core$List$foldr, $elm$core$List$append, _List_Nil, lists);
};
var $elm$core$List$concatMap = F2(
	function (f, list) {
		return $elm$core$List$concat(
			A2($elm$core$List$map, f, list));
	});
var $elm$url$Url$Parser$oneOf = function (parsers) {
	return function (state) {
		return A2(
			$elm$core$List$concatMap,
			function (_v0) {
				var parser = _v0;
				return parser(state);
			},
			parsers);
	};
};
var $elm$url$Url$Parser$s = function (str) {
	return function (_v0) {
		var visited = _v0.ar;
		var unvisited = _v0.aa;
		var params = _v0.ak;
		var frag = _v0.ag;
		var value = _v0.U;
		if (!unvisited.b) {
			return _List_Nil;
		} else {
			var next = unvisited.a;
			var rest = unvisited.b;
			return _Utils_eq(next, str) ? _List_fromArray(
				[
					A5(
					$elm$url$Url$Parser$State,
					A2($elm$core$List$cons, next, visited),
					rest,
					params,
					frag,
					value)
				]) : _List_Nil;
		}
	};
};
var $elm$url$Url$Parser$slash = F2(
	function (_v0, _v1) {
		var parseBefore = _v0;
		var parseAfter = _v1;
		return function (state) {
			return A2(
				$elm$core$List$concatMap,
				parseAfter,
				parseBefore(state));
		};
	});
var $elm$url$Url$Parser$custom = F2(
	function (tipe, stringToSomething) {
		return function (_v0) {
			var visited = _v0.ar;
			var unvisited = _v0.aa;
			var params = _v0.ak;
			var frag = _v0.ag;
			var value = _v0.U;
			if (!unvisited.b) {
				return _List_Nil;
			} else {
				var next = unvisited.a;
				var rest = unvisited.b;
				var _v2 = stringToSomething(next);
				if (!_v2.$) {
					var nextValue = _v2.a;
					return _List_fromArray(
						[
							A5(
							$elm$url$Url$Parser$State,
							A2($elm$core$List$cons, next, visited),
							rest,
							params,
							frag,
							value(nextValue))
						]);
				} else {
					return _List_Nil;
				}
			}
		};
	});
var $elm$url$Url$Parser$string = A2($elm$url$Url$Parser$custom, 'STRING', $elm$core$Maybe$Just);
var $elm$url$Url$Parser$top = function (state) {
	return _List_fromArray(
		[state]);
};
var $author$project$Routes$routes = $elm$url$Url$Parser$oneOf(
	_List_fromArray(
		[
			A2($elm$url$Url$Parser$map, $author$project$Routes$Home, $elm$url$Url$Parser$top),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$Auth,
			$elm$url$Url$Parser$s('register')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$NewEditor,
			$elm$url$Url$Parser$s('editor')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$Editor,
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('editor'),
				$elm$url$Url$Parser$string)),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$Login,
			$elm$url$Url$Parser$s('login')),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$Article,
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('article'),
				$elm$url$Url$Parser$string)),
			A2(
			$elm$url$Url$Parser$map,
			function (s) {
				return A2($author$project$Routes$Profile, s, 0);
			},
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('profile'),
				A2(
					$elm$url$Url$Parser$slash,
					$elm$url$Url$Parser$string,
					$elm$url$Url$Parser$s('favorites')))),
			A2(
			$elm$url$Url$Parser$map,
			function (s) {
				return A2($author$project$Routes$Profile, s, 1);
			},
			A2(
				$elm$url$Url$Parser$slash,
				$elm$url$Url$Parser$s('profile'),
				$elm$url$Url$Parser$string)),
			A2(
			$elm$url$Url$Parser$map,
			$author$project$Routes$Settings,
			$elm$url$Url$Parser$s('settings'))
		]));
var $elm$core$Maybe$withDefault = F2(
	function (_default, maybe) {
		if (!maybe.$) {
			var value = maybe.a;
			return value;
		} else {
			return _default;
		}
	});
var $author$project$Routes$match = function (url) {
	return A2(
		$elm$url$Url$Parser$parse,
		$author$project$Routes$routes,
		_Utils_update(
			url,
			{
				bB: $elm$core$Maybe$Nothing,
				c6: A2($elm$core$Maybe$withDefault, '', url.bB)
			}));
};
var $author$project$Main$Article = function (a) {
	return {$: 4, a: a};
};
var $author$project$Main$Auth = function (a) {
	return {$: 1, a: a};
};
var $author$project$Main$AuthMessage = function (a) {
	return {$: 3, a: a};
};
var $author$project$Main$Editor = function (a) {
	return {$: 2, a: a};
};
var $author$project$Main$EditorMessage = function (a) {
	return {$: 4, a: a};
};
var $author$project$Main$GotArticleAndComments = function (a) {
	return {$: 12, a: a};
};
var $author$project$Main$GotGFAndTags = function (a) {
	return {$: 15, a: a};
};
var $author$project$Main$GotProfileAndArticles = function (a) {
	return {$: 13, a: a};
};
var $author$project$Main$GotProfileAndFavArticles = function (a) {
	return {$: 14, a: a};
};
var $author$project$Main$Login = function (a) {
	return {$: 3, a: a};
};
var $author$project$Main$LoginMessage = function (a) {
	return {$: 5, a: a};
};
var $author$project$Main$Profile = function (a) {
	return {$: 5, a: a};
};
var $author$project$Main$PublicFeed = function (a) {
	return {$: 0, a: a};
};
var $author$project$Main$Settings = function (a) {
	return {$: 6, a: a};
};
var $elm$core$Basics$composeL = F3(
	function (g, f, x) {
		return g(
			f(x));
	});
var $elm$core$Task$onError = _Scheduler_onError;
var $elm$core$Task$attempt = F2(
	function (resultToMessage, task) {
		return $elm$core$Task$command(
			A2(
				$elm$core$Task$onError,
				A2(
					$elm$core$Basics$composeL,
					A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
					$elm$core$Result$Err),
				A2(
					$elm$core$Task$andThen,
					A2(
						$elm$core$Basics$composeL,
						A2($elm$core$Basics$composeL, $elm$core$Task$succeed, resultToMessage),
						$elm$core$Result$Ok),
					task)));
	});
var $author$project$Article$Article = function (slug) {
	return function (title) {
		return function (description) {
			return function (body) {
				return function (tagList) {
					return function (createdAt) {
						return function (updatedAt) {
							return function (favorited) {
								return function (favoritesCount) {
									return function (author) {
										return {h: author, z: body, ae: createdAt, bu: description, aJ: favorited, a5: favoritesCount, J: slug, cf: tagList, bi: title, a2: updatedAt};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Article$Author = F4(
	function (username, bio, image, following) {
		return {aH: bio, aK: following, O: image, j: username};
	});
var $elm$json$Json$Decode$bool = _Json_decodeBool;
var $elm$json$Json$Decode$null = _Json_decodeNull;
var $elm$json$Json$Decode$oneOf = _Json_oneOf;
var $elm$json$Json$Decode$nullable = function (decoder) {
	return $elm$json$Json$Decode$oneOf(
		_List_fromArray(
			[
				$elm$json$Json$Decode$null($elm$core$Maybe$Nothing),
				A2($elm$json$Json$Decode$map, $elm$core$Maybe$Just, decoder)
			]));
};
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom = $elm$json$Json$Decode$map2($elm$core$Basics$apR);
var $elm$json$Json$Decode$field = _Json_decodeField;
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required = F3(
	function (key, valDecoder, decoder) {
		return A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom,
			A2($elm$json$Json$Decode$field, key, valDecoder),
			decoder);
	});
var $elm$json$Json$Decode$string = _Json_decodeString;
var $author$project$Article$authorDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'following',
	$elm$json$Json$Decode$bool,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'image',
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'bio',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'username',
				$elm$json$Json$Decode$string,
				$elm$json$Json$Decode$succeed($author$project$Article$Author)))));
var $elm$json$Json$Decode$int = _Json_decodeInt;
var $elm$json$Json$Decode$list = _Json_decodeList;
var $author$project$Article$articleDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'author',
	$author$project$Article$authorDecoder,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'favoritesCount',
		$elm$json$Json$Decode$int,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'favorited',
			$elm$json$Json$Decode$bool,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'updatedAt',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'createdAt',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tagList',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'body',
							$elm$json$Json$Decode$string,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'description',
								$elm$json$Json$Decode$string,
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'title',
									$elm$json$Json$Decode$string,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'slug',
										$elm$json$Json$Decode$string,
										$elm$json$Json$Decode$succeed($author$project$Article$Article)))))))))));
var $author$project$Main$baseUrl = 'https://api.realworld.io/';
var $elm$http$Http$BadStatus_ = F2(
	function (a, b) {
		return {$: 3, a: a, b: b};
	});
var $elm$http$Http$BadUrl_ = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$GoodStatus_ = F2(
	function (a, b) {
		return {$: 4, a: a, b: b};
	});
var $elm$http$Http$NetworkError_ = {$: 2};
var $elm$http$Http$Receiving = function (a) {
	return {$: 1, a: a};
};
var $elm$http$Http$Sending = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$Timeout_ = {$: 1};
var $elm$core$Maybe$isJust = function (maybe) {
	if (!maybe.$) {
		return true;
	} else {
		return false;
	}
};
var $elm$core$Platform$sendToSelf = _Platform_sendToSelf;
var $elm$http$Http$emptyBody = _Http_emptyBody;
var $elm$http$Http$BadBody = function (a) {
	return {$: 4, a: a};
};
var $elm$http$Http$BadStatus = function (a) {
	return {$: 3, a: a};
};
var $elm$http$Http$BadUrl = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$NetworkError = {$: 2};
var $elm$http$Http$Timeout = {$: 1};
var $elm$json$Json$Decode$decodeString = _Json_runOnString;
var $author$project$Main$handleJsonResponse = F2(
	function (decoder, response) {
		switch (response.$) {
			case 0:
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 1:
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 3:
				var statusCode = response.a.de;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(statusCode));
			case 2:
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			default:
				var body = response.b;
				var _v1 = A2($elm$json$Json$Decode$decodeString, decoder, body);
				if (_v1.$ === 1) {
					return $elm$core$Result$Err(
						$elm$http$Http$BadBody(body));
				} else {
					var result = _v1.a;
					return $elm$core$Result$Ok(result);
				}
		}
	});
var $elm$http$Http$stringResolver = A2(_Http_expect, '', $elm$core$Basics$identity);
var $elm$core$Task$fail = _Scheduler_fail;
var $elm$http$Http$resultToTask = function (result) {
	if (!result.$) {
		var a = result.a;
		return $elm$core$Task$succeed(a);
	} else {
		var x = result.a;
		return $elm$core$Task$fail(x);
	}
};
var $elm$http$Http$task = function (r) {
	return A3(
		_Http_toTask,
		0,
		$elm$http$Http$resultToTask,
		{cq: false, z: r.z, W: r.aW, ah: r.ah, aj: r.aj, an: r.an, ap: $elm$core$Maybe$Nothing, ab: r.ab});
};
var $author$project$Main$fetchArticle2 = function (slug) {
	return $elm$http$Http$task(
		{
			z: $elm$http$Http$emptyBody,
			ah: _List_Nil,
			aj: 'GET',
			aW: $elm$http$Http$stringResolver(
				$author$project$Main$handleJsonResponse(
					A2($elm$json$Json$Decode$field, 'article', $author$project$Article$articleDecoder))),
			an: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + ('api/articles/' + slug)
		});
};
var $author$project$Article$Comment = F5(
	function (id, createdAt, updatedAt, body, author) {
		return {h: author, z: body, ae: createdAt, a7: id, a2: updatedAt};
	});
var $author$project$Article$commentDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'author',
	$author$project$Article$authorDecoder,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'body',
		$elm$json$Json$Decode$string,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'updatedAt',
			$elm$json$Json$Decode$string,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'createdAt',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'id',
					$elm$json$Json$Decode$int,
					$elm$json$Json$Decode$succeed($author$project$Article$Comment))))));
var $author$project$Main$fetchComments2 = function (slug) {
	return $elm$http$Http$task(
		{
			z: $elm$http$Http$emptyBody,
			ah: _List_Nil,
			aj: 'GET',
			aW: $elm$http$Http$stringResolver(
				$author$project$Main$handleJsonResponse(
					A2(
						$elm$json$Json$Decode$field,
						'comments',
						$elm$json$Json$Decode$list($author$project$Article$commentDecoder)))),
			an: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + ('api/articles/' + (slug + '/comments'))
		});
};
var $author$project$Main$fetchArticleAndComments = function (slug) {
	return A2(
		$elm$core$Task$andThen,
		function (article) {
			return A2(
				$elm$core$Task$map,
				function (comments) {
					return _Utils_Tuple2(article, comments);
				},
				$author$project$Main$fetchComments2(slug));
		},
		$author$project$Main$fetchArticle2(slug));
};
var $author$project$Main$GotArticleEditor = function (a) {
	return {$: 11, a: a};
};
var $elm$http$Http$expectStringResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'',
			$elm$core$Basics$identity,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$core$Result$mapError = F2(
	function (f, result) {
		if (!result.$) {
			var v = result.a;
			return $elm$core$Result$Ok(v);
		} else {
			var e = result.a;
			return $elm$core$Result$Err(
				f(e));
		}
	});
var $elm$http$Http$resolve = F2(
	function (toResult, response) {
		switch (response.$) {
			case 0:
				var url = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadUrl(url));
			case 1:
				return $elm$core$Result$Err($elm$http$Http$Timeout);
			case 2:
				return $elm$core$Result$Err($elm$http$Http$NetworkError);
			case 3:
				var metadata = response.a;
				return $elm$core$Result$Err(
					$elm$http$Http$BadStatus(metadata.de));
			default:
				var body = response.b;
				return A2(
					$elm$core$Result$mapError,
					$elm$http$Http$BadBody,
					toResult(body));
		}
	});
var $elm$http$Http$expectJson = F2(
	function (toMsg, decoder) {
		return A2(
			$elm$http$Http$expectStringResponse,
			toMsg,
			$elm$http$Http$resolve(
				function (string) {
					return A2(
						$elm$core$Result$mapError,
						$elm$json$Json$Decode$errorToString,
						A2($elm$json$Json$Decode$decodeString, decoder, string));
				}));
	});
var $elm$http$Http$Request = function (a) {
	return {$: 1, a: a};
};
var $elm$http$Http$State = F2(
	function (reqs, subs) {
		return {b1: reqs, ce: subs};
	});
var $elm$http$Http$init = $elm$core$Task$succeed(
	A2($elm$http$Http$State, $elm$core$Dict$empty, _List_Nil));
var $elm$core$Process$kill = _Scheduler_kill;
var $elm$core$Process$spawn = _Scheduler_spawn;
var $elm$http$Http$updateReqs = F3(
	function (router, cmds, reqs) {
		updateReqs:
		while (true) {
			if (!cmds.b) {
				return $elm$core$Task$succeed(reqs);
			} else {
				var cmd = cmds.a;
				var otherCmds = cmds.b;
				if (!cmd.$) {
					var tracker = cmd.a;
					var _v2 = A2($elm$core$Dict$get, tracker, reqs);
					if (_v2.$ === 1) {
						var $temp$router = router,
							$temp$cmds = otherCmds,
							$temp$reqs = reqs;
						router = $temp$router;
						cmds = $temp$cmds;
						reqs = $temp$reqs;
						continue updateReqs;
					} else {
						var pid = _v2.a;
						return A2(
							$elm$core$Task$andThen,
							function (_v3) {
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A2($elm$core$Dict$remove, tracker, reqs));
							},
							$elm$core$Process$kill(pid));
					}
				} else {
					var req = cmd.a;
					return A2(
						$elm$core$Task$andThen,
						function (pid) {
							var _v4 = req.ap;
							if (_v4.$ === 1) {
								return A3($elm$http$Http$updateReqs, router, otherCmds, reqs);
							} else {
								var tracker = _v4.a;
								return A3(
									$elm$http$Http$updateReqs,
									router,
									otherCmds,
									A3($elm$core$Dict$insert, tracker, pid, reqs));
							}
						},
						$elm$core$Process$spawn(
							A3(
								_Http_toTask,
								router,
								$elm$core$Platform$sendToApp(router),
								req)));
				}
			}
		}
	});
var $elm$http$Http$onEffects = F4(
	function (router, cmds, subs, state) {
		return A2(
			$elm$core$Task$andThen,
			function (reqs) {
				return $elm$core$Task$succeed(
					A2($elm$http$Http$State, reqs, subs));
			},
			A3($elm$http$Http$updateReqs, router, cmds, state.b1));
	});
var $elm$core$List$maybeCons = F3(
	function (f, mx, xs) {
		var _v0 = f(mx);
		if (!_v0.$) {
			var x = _v0.a;
			return A2($elm$core$List$cons, x, xs);
		} else {
			return xs;
		}
	});
var $elm$core$List$filterMap = F2(
	function (f, xs) {
		return A3(
			$elm$core$List$foldr,
			$elm$core$List$maybeCons(f),
			_List_Nil,
			xs);
	});
var $elm$http$Http$maybeSend = F4(
	function (router, desiredTracker, progress, _v0) {
		var actualTracker = _v0.a;
		var toMsg = _v0.b;
		return _Utils_eq(desiredTracker, actualTracker) ? $elm$core$Maybe$Just(
			A2(
				$elm$core$Platform$sendToApp,
				router,
				toMsg(progress))) : $elm$core$Maybe$Nothing;
	});
var $elm$http$Http$onSelfMsg = F3(
	function (router, _v0, state) {
		var tracker = _v0.a;
		var progress = _v0.b;
		return A2(
			$elm$core$Task$andThen,
			function (_v1) {
				return $elm$core$Task$succeed(state);
			},
			$elm$core$Task$sequence(
				A2(
					$elm$core$List$filterMap,
					A3($elm$http$Http$maybeSend, router, tracker, progress),
					state.ce)));
	});
var $elm$http$Http$Cancel = function (a) {
	return {$: 0, a: a};
};
var $elm$http$Http$cmdMap = F2(
	function (func, cmd) {
		if (!cmd.$) {
			var tracker = cmd.a;
			return $elm$http$Http$Cancel(tracker);
		} else {
			var r = cmd.a;
			return $elm$http$Http$Request(
				{
					cq: r.cq,
					z: r.z,
					W: A2(_Http_mapExpect, func, r.W),
					ah: r.ah,
					aj: r.aj,
					an: r.an,
					ap: r.ap,
					ab: r.ab
				});
		}
	});
var $elm$http$Http$MySub = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$http$Http$subMap = F2(
	function (func, _v0) {
		var tracker = _v0.a;
		var toMsg = _v0.b;
		return A2(
			$elm$http$Http$MySub,
			tracker,
			A2($elm$core$Basics$composeR, toMsg, func));
	});
_Platform_effectManagers['Http'] = _Platform_createManager($elm$http$Http$init, $elm$http$Http$onEffects, $elm$http$Http$onSelfMsg, $elm$http$Http$cmdMap, $elm$http$Http$subMap);
var $elm$http$Http$command = _Platform_leaf('Http');
var $elm$http$Http$subscription = _Platform_leaf('Http');
var $elm$http$Http$request = function (r) {
	return $elm$http$Http$command(
		$elm$http$Http$Request(
			{cq: false, z: r.z, W: r.W, ah: r.ah, aj: r.aj, an: r.an, ap: r.ap, ab: r.ab}));
};
var $elm$http$Http$get = function (r) {
	return $elm$http$Http$request(
		{z: $elm$http$Http$emptyBody, W: r.W, ah: _List_Nil, aj: 'GET', an: $elm$core$Maybe$Nothing, ap: $elm$core$Maybe$Nothing, ab: r.ab});
};
var $author$project$Main$fetchArticleEditor = function (slug) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Main$GotArticleEditor,
				A2($elm$json$Json$Decode$field, 'article', $author$project$Article$articleDecoder)),
			ab: $author$project$Main$baseUrl + ('api/articles/' + slug)
		});
};
var $author$project$Main$fetchGlobalFeed = $elm$http$Http$task(
	{
		z: $elm$http$Http$emptyBody,
		ah: _List_Nil,
		aj: 'GET',
		aW: $elm$http$Http$stringResolver(
			$author$project$Main$handleJsonResponse(
				A2(
					$elm$json$Json$Decode$field,
					'articles',
					$elm$json$Json$Decode$list($author$project$Article$articleDecoder)))),
		an: $elm$core$Maybe$Nothing,
		ab: $author$project$Main$baseUrl + 'api/articles'
	});
var $author$project$Index$tagDecoder = A2(
	$elm$json$Json$Decode$field,
	'tags',
	$elm$json$Json$Decode$list($elm$json$Json$Decode$string));
var $author$project$Main$fetchTags = $elm$http$Http$task(
	{
		z: $elm$http$Http$emptyBody,
		ah: _List_Nil,
		aj: 'GET',
		aW: $elm$http$Http$stringResolver(
			$author$project$Main$handleJsonResponse($author$project$Index$tagDecoder)),
		an: $elm$core$Maybe$Nothing,
		ab: $author$project$Main$baseUrl + 'api/tags'
	});
var $author$project$Main$fetchGlobalFeedAndTags = A2(
	$elm$core$Task$andThen,
	function (articles) {
		return A2(
			$elm$core$Task$map,
			function (tags) {
				return _Utils_Tuple2(articles, tags);
			},
			$author$project$Main$fetchTags);
	},
	$author$project$Main$fetchGlobalFeed);
var $author$project$Profile$ProfileType = F4(
	function (username, bio, image, following) {
		return {aH: bio, aK: following, O: image, j: username};
	});
var $author$project$Profile$profileDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'following',
	$elm$json$Json$Decode$bool,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'image',
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'bio',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'username',
				$elm$json$Json$Decode$string,
				$elm$json$Json$Decode$succeed($author$project$Profile$ProfileType)))));
var $author$project$Main$fetchProfile2 = function (username) {
	return $elm$http$Http$task(
		{
			z: $elm$http$Http$emptyBody,
			ah: _List_Nil,
			aj: 'GET',
			aW: $elm$http$Http$stringResolver(
				$author$project$Main$handleJsonResponse(
					A2($elm$json$Json$Decode$field, 'profile', $author$project$Profile$profileDecoder))),
			an: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + ('api/profiles/' + username)
		});
};
var $author$project$Main$fetchProfileArticles2 = function (username) {
	return $elm$http$Http$task(
		{
			z: $elm$http$Http$emptyBody,
			ah: _List_Nil,
			aj: 'GET',
			aW: $elm$http$Http$stringResolver(
				$author$project$Main$handleJsonResponse(
					A2(
						$elm$json$Json$Decode$field,
						'articles',
						$elm$json$Json$Decode$list($author$project$Article$articleDecoder)))),
			an: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + ('api/articles?author=' + username)
		});
};
var $author$project$Main$fetchProfileAndArticles = function (slug) {
	return A2(
		$elm$core$Task$andThen,
		function (article) {
			return A2(
				$elm$core$Task$map,
				function (comments) {
					return _Utils_Tuple2(article, comments);
				},
				$author$project$Main$fetchProfileArticles2(slug));
		},
		$author$project$Main$fetchProfile2(slug));
};
var $author$project$Main$fetchFavoritedArticles = function (username) {
	return $elm$http$Http$task(
		{
			z: $elm$http$Http$emptyBody,
			ah: _List_Nil,
			aj: 'GET',
			aW: $elm$http$Http$stringResolver(
				$author$project$Main$handleJsonResponse(
					A2(
						$elm$json$Json$Decode$field,
						'articles',
						$elm$json$Json$Decode$list($author$project$Article$articleDecoder)))),
			an: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + ('api/articles?favorited=' + username)
		});
};
var $author$project$Main$fetchProfileAndFavArticles = function (slug) {
	return A2(
		$elm$core$Task$andThen,
		function (article) {
			return A2(
				$elm$core$Task$map,
				function (comments) {
					return _Utils_Tuple2(article, comments);
				},
				$author$project$Main$fetchFavoritedArticles(slug));
		},
		$author$project$Main$fetchProfile2(slug));
};
var $author$project$Main$GotUser = function (a) {
	return {$: 10, a: a};
};
var $elm$http$Http$Header = F2(
	function (a, b) {
		return {$: 0, a: a, b: b};
	});
var $elm$http$Http$header = $elm$http$Http$Header;
var $author$project$Main$User = F5(
	function (email, token, username, bio, image) {
		return {aH: bio, bw: email, O: image, T: token, j: username};
	});
var $author$project$Main$userDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'image',
	$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'bio',
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'username',
			$elm$json$Json$Decode$string,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'token',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'email',
					$elm$json$Json$Decode$string,
					$elm$json$Json$Decode$succeed($author$project$Main$User))))));
var $author$project$Main$getUser = function (user) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + user.T)
		]);
	return $elm$http$Http$request(
		{
			z: $elm$http$Http$emptyBody,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Main$GotUser,
				A2($elm$json$Json$Decode$field, 'user', $author$project$Main$userDecoder)),
			ah: headers,
			aj: 'GET',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Main$baseUrl + 'api/user'
		});
};
var $author$project$Article$defaultAuthor = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just('http://i.imgur.com/Qr71crq.jpg'),
	j: 'Eric Simons'
};
var $author$project$Article$defaultArticle = {
	h: $author$project$Article$defaultAuthor,
	z: '',
	ae: 'January 20th',
	bu: '',
	aJ: false,
	a5: 29,
	J: 'slug1',
	cf: _List_fromArray(
		['']),
	bi: 'How to build webapps that scale',
	a2: 'January 20th'
};
var $author$project$Article$defaultComment = {h: $author$project$Article$defaultAuthor, z: 'With supporting text below as a natural lead-in to additional content.', ae: 'Dec 29th', a7: 0, a2: ''};
var $author$project$Article$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Article$initialModel = {
	d: $author$project$Article$defaultArticle,
	as: $elm$core$Maybe$Just(
		_List_fromArray(
			[$author$project$Article$defaultComment])),
	Q: '',
	D: $author$project$Article$defaultUser
};
var $elm$core$Platform$Cmd$batch = _Platform_batch;
var $elm$core$Platform$Cmd$none = $elm$core$Platform$Cmd$batch(_List_Nil);
var $author$project$Article$init = _Utils_Tuple2($author$project$Article$initialModel, $elm$core$Platform$Cmd$none);
var $author$project$Auth$initialModel = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	au: $elm$core$Maybe$Just(''),
	aS: '',
	O: $elm$core$Maybe$Just(''),
	R: '',
	ay: $elm$core$Maybe$Just(''),
	be: false,
	T: '',
	j: '',
	aB: $elm$core$Maybe$Just('')
};
var $author$project$Auth$init = _Utils_Tuple2($author$project$Auth$initialModel, $elm$core$Platform$Cmd$none);
var $author$project$Editor$defaultAuthor = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just(''),
	j: ''
};
var $author$project$Editor$defaultArticle = {
	h: $author$project$Editor$defaultAuthor,
	z: '',
	ae: '',
	bu: '',
	aJ: false,
	a5: 0,
	J: '',
	cf: _List_fromArray(
		['']),
	bi: '',
	a2: ''
};
var $author$project$Editor$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Editor$initialModel = {
	d: $author$project$Editor$defaultArticle,
	ad: $elm$core$Maybe$Just(''),
	br: false,
	af: $elm$core$Maybe$Just(''),
	aO: '',
	ao: $elm$core$Maybe$Just(''),
	D: $author$project$Editor$defaultUser
};
var $author$project$Editor$init = _Utils_Tuple2($author$project$Editor$initialModel, $elm$core$Platform$Cmd$none);
var $author$project$Index$GotGlobalFeed = function (a) {
	return {$: 1, a: a};
};
var $author$project$Index$Article = function (slug) {
	return function (title) {
		return function (description) {
			return function (body) {
				return function (tagList) {
					return function (createdAt) {
						return function (updatedAt) {
							return function (favorited) {
								return function (favoritesCount) {
									return function (author) {
										return {h: author, z: body, ae: createdAt, bu: description, aJ: favorited, a5: favoritesCount, J: slug, cf: tagList, bi: title, a2: updatedAt};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Editor$Author = F4(
	function (username, bio, image, following) {
		return {aH: bio, aK: following, O: image, j: username};
	});
var $author$project$Editor$authorDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'following',
	$elm$json$Json$Decode$bool,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'image',
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'bio',
			$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'username',
				$elm$json$Json$Decode$string,
				$elm$json$Json$Decode$succeed($author$project$Editor$Author)))));
var $author$project$Index$articleDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'author',
	$author$project$Editor$authorDecoder,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'favoritesCount',
		$elm$json$Json$Decode$int,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'favorited',
			$elm$json$Json$Decode$bool,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'updatedAt',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'createdAt',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tagList',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'body',
							$elm$json$Json$Decode$string,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'description',
								$elm$json$Json$Decode$string,
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'title',
									$elm$json$Json$Decode$string,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'slug',
										$elm$json$Json$Decode$string,
										$elm$json$Json$Decode$succeed($author$project$Index$Article)))))))))));
var $author$project$Auth$baseUrl = 'https://api.realworld.io/';
var $author$project$Index$fetchGlobalArticles = $elm$http$Http$get(
	{
		W: A2(
			$elm$http$Http$expectJson,
			$author$project$Index$GotGlobalFeed,
			A2(
				$elm$json$Json$Decode$field,
				'articles',
				$elm$json$Json$Decode$list($author$project$Index$articleDecoder))),
		ab: $author$project$Auth$baseUrl + 'api/articles'
	});
var $author$project$Index$GotTags = function (a) {
	return {$: 2, a: a};
};
var $author$project$Index$fetchTags2 = $elm$http$Http$get(
	{
		W: A2($elm$http$Http$expectJson, $author$project$Index$GotTags, $author$project$Index$tagDecoder),
		ab: $author$project$Auth$baseUrl + 'api/tags'
	});
var $author$project$Index$author1 = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just('http://i.imgur.com/Qr71crq.jpg'),
	j: 'Eric Simons'
};
var $author$project$Index$articlePreview1 = {
	h: $author$project$Index$author1,
	z: '',
	ae: 'January 20th',
	bu: 'In my demo, the holy grail layout is nested inside a document, so there\'s no body or main tags like shown above. Regardless, we\'re interested in the class names \r\n                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and \r\n                        the trivial order in which they appear in the markup. Let\'s break this down to paint a clear picture of what\'s happening...',
	aJ: false,
	a5: 29,
	J: 'slug1',
	cf: _List_fromArray(
		['']),
	bi: 'How to build webapps that scale',
	a2: ''
};
var $author$project$Index$author2 = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just('http://i.imgur.com/N4VcUeJ.jpg'),
	j: 'Albert Pai'
};
var $author$project$Index$articlePreview2 = {
	h: $author$project$Index$author2,
	z: '',
	ae: 'January 20th',
	bu: 'In my demo, the holy grail layout is nested inside a document, so there\'s no body or main tags like shown above. Regardless, we\'re interested in the class names \r\n                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and \r\n                        the trivial order in which they appear in the markup. Let\'s break this down to paint a clear picture of what\'s happening...',
	aJ: false,
	a5: 32,
	J: 'slug2',
	cf: _List_fromArray(
		['']),
	bi: 'The song you won\'t ever stop singing. No matter how hard you try.',
	a2: ''
};
var $author$project$Index$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Index$initialModel = {
	aU: $elm$core$Maybe$Just(
		_List_fromArray(
			[$author$project$Index$articlePreview1, $author$project$Index$articlePreview2])),
	S: true,
	_: false,
	am: '',
	a_: $elm$core$Maybe$Just(_List_Nil),
	a$: $elm$core$Maybe$Just(
		_List_fromArray(
			[' programming', ' javascript', ' angularjs', ' react', ' mean', ' node', ' rails'])),
	D: $author$project$Index$defaultUser,
	a3: $elm$core$Maybe$Just(_List_Nil)
};
var $author$project$Index$init = _Utils_Tuple2(
	$author$project$Index$initialModel,
	$elm$core$Platform$Cmd$batch(
		_List_fromArray(
			[$author$project$Index$fetchGlobalArticles, $author$project$Index$fetchTags2])));
var $author$project$Login$init = _Utils_Tuple2($author$project$Auth$initialModel, $elm$core$Platform$Cmd$none);
var $author$project$Profile$defaultProfile = {
	aH: $elm$core$Maybe$Just(''),
	aK: false,
	O: $elm$core$Maybe$Just(''),
	j: ''
};
var $author$project$Profile$articlePreview1 = {
	h: $author$project$Profile$defaultProfile,
	z: '',
	ae: 'January 20th',
	bu: 'In my demo, the holy grail layout is nested inside a document, so there\'s no body or main tags like shown above. Regardless, we\'re interested in the class names \r\n                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and \r\n                        the trivial order in which they appear in the markup. Let\'s break this down to paint a clear picture of what\'s happening...',
	aJ: false,
	a5: 29,
	J: 'slug1',
	cf: _List_fromArray(
		['']),
	bi: 'How to build webapps that scale',
	a2: ''
};
var $author$project$Profile$articlePreview2 = {
	h: $author$project$Profile$defaultProfile,
	z: '',
	ae: 'January 20th',
	bu: 'In my demo, the holy grail layout is nested inside a document, so there\'s no body or main tags like shown above. Regardless, we\'re interested in the class names \r\n                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and \r\n                        the trivial order in which they appear in the markup. Let\'s break this down to paint a clear picture of what\'s happening...',
	aJ: false,
	a5: 32,
	J: 'slug2',
	cf: _List_fromArray(
		['']),
	bi: 'The song you won\'t ever stop singing. No matter how hard you try.',
	a2: ''
};
var $author$project$Profile$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Profile$initialModel = {
	E: $elm$core$Maybe$Just(
		_List_fromArray(
			[$author$project$Profile$articlePreview1, $author$project$Profile$articlePreview2])),
	aw: $elm$core$Maybe$Just(_List_Nil),
	x: $author$project$Profile$defaultProfile,
	az: true,
	D: $author$project$Profile$defaultUser
};
var $author$project$Profile$init = _Utils_Tuple2($author$project$Profile$initialModel, $elm$core$Platform$Cmd$none);
var $author$project$Settings$defaultUser = {
	aH: $elm$core$Maybe$Just(''),
	bw: '',
	O: $elm$core$Maybe$Just(''),
	T: '',
	j: ''
};
var $author$project$Settings$initialModel = {
	au: $elm$core$Maybe$Just(''),
	aS: '',
	R: '',
	ay: $elm$core$Maybe$Just(''),
	dm: false,
	D: $author$project$Settings$defaultUser,
	aB: $elm$core$Maybe$Just('')
};
var $author$project$Settings$init = _Utils_Tuple2($author$project$Settings$initialModel, $elm$core$Platform$Cmd$none);
var $elm$core$Platform$Cmd$map = _Platform_map;
var $author$project$Main$setNewPage = F2(
	function (maybeRoute, model) {
		if (!maybeRoute.$) {
			switch (maybeRoute.a.$) {
				case 0:
					var _v1 = maybeRoute.a;
					var _v2 = $author$project$Index$init;
					var publicFeedModel = _v2.a;
					var publicFeedCmd = _v2.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Home',
								e: $author$project$Main$PublicFeed(
									_Utils_update(
										publicFeedModel,
										{D: model.D}))
							}),
						A2($elm$core$Task$attempt, $author$project$Main$GotGFAndTags, $author$project$Main$fetchGlobalFeedAndTags));
				case 1:
					var _v3 = maybeRoute.a;
					var _v4 = $author$project$Auth$init;
					var authUser = _v4.a;
					var authCmd = _v4.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Auth',
								e: $author$project$Main$Auth(authUser)
							}),
						A2($elm$core$Platform$Cmd$map, $author$project$Main$AuthMessage, authCmd));
				case 2:
					var _v5 = maybeRoute.a;
					var _v6 = $author$project$Editor$init;
					var editorModel = _v6.a;
					var editorCmd = _v6.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Editor',
								e: $author$project$Main$Editor(
									{
										d: $author$project$Main$defaultArticle,
										ad: $elm$core$Maybe$Just(''),
										br: false,
										af: $elm$core$Maybe$Just(''),
										aO: '',
										ao: $elm$core$Maybe$Just(''),
										D: model.D
									})
							}),
						A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMessage, editorCmd));
				case 3:
					var slug = maybeRoute.a.a;
					var _v7 = $author$project$Editor$init;
					var editorModel = _v7.a;
					var editorCmd = _v7.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Editor',
								e: $author$project$Main$Editor(
									{
										d: $author$project$Main$defaultArticle,
										ad: $elm$core$Maybe$Just(''),
										br: false,
										af: $elm$core$Maybe$Just(''),
										aO: '',
										ao: $elm$core$Maybe$Just(''),
										D: model.D
									})
							}),
						$author$project$Main$fetchArticleEditor(slug));
				case 4:
					var _v8 = maybeRoute.a;
					var _v9 = $author$project$Login$init;
					var loginUser = _v9.a;
					var loginCmd = _v9.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Login',
								e: $author$project$Main$Login(loginUser)
							}),
						A2($elm$core$Platform$Cmd$map, $author$project$Main$LoginMessage, loginCmd));
				case 5:
					var slug = maybeRoute.a.a;
					var _v10 = $author$project$Article$init;
					var articleModel = _v10.a;
					var articleCmd = _v10.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								e: $author$project$Main$Article(articleModel)
							}),
						A2(
							$elm$core$Task$attempt,
							$author$project$Main$GotArticleAndComments,
							$author$project$Main$fetchArticleAndComments(slug)));
				case 6:
					var _v11 = maybeRoute.a;
					var username = _v11.a;
					var dest = _v11.b;
					if (dest === 1) {
						var _v13 = $author$project$Profile$init;
						var profileModel = _v13.a;
						var profileCmd = _v13.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									m: _Utils_eq(model.D.j, username) ? 'Profile' : '',
									e: $author$project$Main$Profile(profileModel)
								}),
							A2(
								$elm$core$Task$attempt,
								$author$project$Main$GotProfileAndArticles,
								$author$project$Main$fetchProfileAndArticles(username)));
					} else {
						var _v14 = $author$project$Profile$init;
						var profileModel = _v14.a;
						var profileCmd = _v14.b;
						return _Utils_Tuple2(
							_Utils_update(
								model,
								{
									m: _Utils_eq(model.D.j, username) ? 'Profile' : '',
									e: $author$project$Main$Profile(profileModel)
								}),
							A2(
								$elm$core$Task$attempt,
								$author$project$Main$GotProfileAndFavArticles,
								$author$project$Main$fetchProfileAndFavArticles(username)));
					}
				default:
					var _v15 = maybeRoute.a;
					var _v16 = $author$project$Settings$init;
					var settingsUserSettings = _v16.a;
					var settingsCmd = _v16.b;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								m: 'Settings',
								e: $author$project$Main$Settings(settingsUserSettings)
							}),
						$author$project$Main$getUser(model.D));
			}
		} else {
			return _Utils_Tuple2(
				_Utils_update(
					model,
					{m: 'NotFound', e: $author$project$Main$NotFound}),
				$elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Main$init = F3(
	function (_v0, url, navigationKey) {
		return A2(
			$author$project$Main$setNewPage,
			$author$project$Routes$match(url),
			A2($author$project$Main$initialModel, navigationKey, url));
	});
var $elm$core$Platform$Sub$batch = _Platform_batch;
var $elm$core$Platform$Sub$none = $elm$core$Platform$Sub$batch(_List_Nil);
var $author$project$Main$subscriptions = function (model) {
	return $elm$core$Platform$Sub$none;
};
var $author$project$Main$ArticleMessage = function (a) {
	return {$: 6, a: a};
};
var $author$project$Main$ProfileMessage = function (a) {
	return {$: 7, a: a};
};
var $author$project$Main$PublicFeedMessage = function (a) {
	return {$: 2, a: a};
};
var $author$project$Main$SettingsMessage = function (a) {
	return {$: 8, a: a};
};
var $author$project$Main$convertUser = function (regUser) {
	return {aH: regUser.aH, bw: regUser.bw, O: regUser.O, T: regUser.T, j: regUser.j};
};
var $author$project$Main$GotProfile = function (a) {
	return {$: 9, a: a};
};
var $author$project$Main$fetchProfile = function (username) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Main$GotProfile,
				A2($elm$json$Json$Decode$field, 'profile', $author$project$Profile$profileDecoder)),
			ab: $author$project$Main$baseUrl + ('api/profiles/' + username)
		});
};
var $elm$browser$Browser$Navigation$load = _Browser_load;
var $elm$browser$Browser$Navigation$pushUrl = _Browser_pushUrl;
var $elm$url$Url$addPort = F2(
	function (maybePort, starter) {
		if (maybePort.$ === 1) {
			return starter;
		} else {
			var port_ = maybePort.a;
			return starter + (':' + $elm$core$String$fromInt(port_));
		}
	});
var $elm$url$Url$addPrefixed = F3(
	function (prefix, maybeSegment, starter) {
		if (maybeSegment.$ === 1) {
			return starter;
		} else {
			var segment = maybeSegment.a;
			return _Utils_ap(
				starter,
				_Utils_ap(prefix, segment));
		}
	});
var $elm$url$Url$toString = function (url) {
	var http = function () {
		var _v0 = url.b_;
		if (!_v0) {
			return 'http://';
		} else {
			return 'https://';
		}
	}();
	return A3(
		$elm$url$Url$addPrefixed,
		'#',
		url.bB,
		A3(
			$elm$url$Url$addPrefixed,
			'?',
			url.b$,
			_Utils_ap(
				A2(
					$elm$url$Url$addPort,
					url.bW,
					_Utils_ap(http, url.bH)),
				url.c6)));
};
var $author$project$Article$addComment = F2(
	function (newComment, oldComments) {
		if (!oldComments.$) {
			var comments = oldComments.a;
			return $elm$core$Maybe$Just(
				A2(
					$elm$core$List$append,
					comments,
					_List_fromArray(
						[newComment])));
		} else {
			return $elm$core$Maybe$Just(
				_List_fromArray(
					[newComment]));
		}
	});
var $elm$core$String$trim = _String_trim;
var $author$project$Article$checkNewComment = function (newComment) {
	var comment = $elm$core$String$trim(newComment);
	if (comment === '') {
		return false;
	} else {
		return true;
	}
};
var $author$project$Article$GotComment = function (a) {
	return {$: 9, a: a};
};
var $author$project$Article$baseUrl = 'https://api.realworld.io/';
var $elm$json$Json$Encode$object = function (pairs) {
	return _Json_wrap(
		A3(
			$elm$core$List$foldl,
			F2(
				function (_v0, obj) {
					var k = _v0.a;
					var v = _v0.b;
					return A3(_Json_addField, k, v, obj);
				}),
			_Json_emptyObject(0),
			pairs));
};
var $elm$json$Json$Encode$string = _Json_wrap;
var $author$project$Article$encodeComment = function (comment) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'body',
				$elm$json$Json$Encode$string(comment))
			]));
};
var $elm$http$Http$jsonBody = function (value) {
	return A2(
		_Http_pair,
		'application/json',
		A2($elm$json$Json$Encode$encode, 0, value));
};
var $author$project$Article$createComment = F2(
	function (model, comment) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'comment',
						$author$project$Article$encodeComment(comment))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Article$GotComment,
					A2($elm$json$Json$Decode$field, 'comment', $author$project$Article$commentDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/articles/' + (model.d.J + '/comments'))
			});
	});
var $author$project$Article$DeletedArticle = function (a) {
	return {$: 12, a: a};
};
var $author$project$Article$encodeArticle = function (article) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'slug',
				$elm$json$Json$Encode$string(article.J))
			]));
};
var $elm$http$Http$expectBytesResponse = F2(
	function (toMsg, toResult) {
		return A3(
			_Http_expect,
			'arraybuffer',
			_Http_toDataView,
			A2($elm$core$Basics$composeR, toResult, toMsg));
	});
var $elm$http$Http$expectWhatever = function (toMsg) {
	return A2(
		$elm$http$Http$expectBytesResponse,
		toMsg,
		$elm$http$Http$resolve(
			function (_v0) {
				return $elm$core$Result$Ok(0);
			}));
};
var $author$project$Article$deleteArticle = function (model) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
		]);
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'article',
					$author$project$Article$encodeArticle(model.d))
				])));
	return $elm$http$Http$request(
		{
			z: body,
			W: $elm$http$Http$expectWhatever($author$project$Article$DeletedArticle),
			ah: headers,
			aj: 'DELETE',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Article$baseUrl + ('api/articles/' + model.d.J)
		});
};
var $author$project$Article$DeleteResponse = function (a) {
	return {$: 10, a: a};
};
var $author$project$Article$deleteComment = F2(
	function (model, id) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		return $elm$http$Http$request(
			{
				z: $elm$http$Http$emptyBody,
				W: $elm$http$Http$expectWhatever($author$project$Article$DeleteResponse),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/articles/' + (model.d.J + ('/comments/' + $elm$core$String$fromInt(id))))
			});
	});
var $author$project$Article$GotArticle = function (a) {
	return {$: 5, a: a};
};
var $author$project$Article$favoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Article$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Article$GotArticle,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Article$articleDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Article$GotComments = function (a) {
	return {$: 8, a: a};
};
var $author$project$Article$fetchComments = function (slug) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Article$GotComments,
				A2(
					$elm$json$Json$Decode$field,
					'comments',
					$elm$json$Json$Decode$list($author$project$Article$commentDecoder))),
			ab: $author$project$Article$baseUrl + ('api/articles/' + (slug + '/comments'))
		});
};
var $author$project$Article$GotAuthor = function (a) {
	return {$: 6, a: a};
};
var $elm$json$Json$Encode$null = _Json_encodeNull;
var $author$project$Article$encodeMaybeString = function (maybeString) {
	if (!maybeString.$) {
		var string = maybeString.a;
		return $elm$json$Json$Encode$string(string);
	} else {
		return $elm$json$Json$Encode$null;
	}
};
var $author$project$Article$encodeAuthor = function (author) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(author.j)),
				_Utils_Tuple2(
				'bio',
				$author$project$Article$encodeMaybeString(author.aH)),
				_Utils_Tuple2(
				'image',
				$author$project$Article$encodeMaybeString(author.O))
			]));
};
var $author$project$Article$followUser = F2(
	function (model, author) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'profile',
						$author$project$Article$encodeAuthor(author))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Article$GotAuthor,
					A2($elm$json$Json$Decode$field, 'profile', $author$project$Article$authorDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/profiles/' + (author.j + '/follow'))
			});
	});
var $author$project$Article$unfavoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Article$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Article$GotArticle,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Article$articleDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Article$unfollowUser = F2(
	function (model, author) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'profile',
						$author$project$Article$encodeAuthor(author))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Article$GotAuthor,
					A2($elm$json$Json$Decode$field, 'profile', $author$project$Article$authorDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Article$baseUrl + ('api/profiles/' + (author.j + '/follow'))
			});
	});
var $author$project$Article$updateAuthor = F2(
	function (article, author) {
		return _Utils_update(
			article,
			{h: author});
	});
var $author$project$Article$update = F2(
	function (message, model) {
		switch (message.$) {
			case 0:
				return model.d.aJ ? _Utils_Tuple2(
					model,
					A2($author$project$Article$unfavoriteArticle, model, model.d)) : _Utils_Tuple2(
					model,
					A2($author$project$Article$favoriteArticle, model, model.d));
			case 1:
				return model.d.h.aK ? _Utils_Tuple2(
					model,
					A2($author$project$Article$unfollowUser, model, model.d.h)) : _Utils_Tuple2(
					model,
					A2($author$project$Article$followUser, model, model.d.h));
			case 2:
				var comment = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{Q: comment}),
					$elm$core$Platform$Cmd$none);
			case 3:
				var comment = message.a;
				return $author$project$Article$checkNewComment(comment) ? _Utils_Tuple2(
					model,
					A2($author$project$Article$createComment, model, comment)) : _Utils_Tuple2(
					_Utils_update(
						model,
						{Q: ''}),
					$elm$core$Platform$Cmd$none);
			case 4:
				var id = message.a;
				return _Utils_Tuple2(
					model,
					A2($author$project$Article$deleteComment, model, id));
			case 5:
				if (!message.a.$) {
					var article = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{d: article}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 6:
				if (!message.a.$) {
					var author = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								d: A2($author$project$Article$updateAuthor, model.d, author)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 7:
				return _Utils_Tuple2(
					model,
					$author$project$Article$deleteArticle(model));
			case 8:
				if (!message.a.$) {
					var comments = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								as: $elm$core$Maybe$Just(comments)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 9:
				if (!message.a.$) {
					var comment = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								as: A2($author$project$Article$addComment, comment, model.as),
								Q: ''
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{Q: ''}),
						$elm$core$Platform$Cmd$none);
				}
			case 10:
				return _Utils_Tuple2(
					model,
					$author$project$Article$fetchComments(model.d.J));
			case 11:
				var username = message.a;
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			default:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Auth$isFormValid = function (user) {
	return (A2($elm$core$Maybe$withDefault, '', user.aB) === '') && ((A2($elm$core$Maybe$withDefault, '', user.au) === '') && (A2($elm$core$Maybe$withDefault, '', user.ay) === ''));
};
var $author$project$Auth$SignedUpGoHome = function (a) {
	return {$: 4, a: a};
};
var $author$project$Auth$encodeUser = function (user) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(user.j)),
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(user.bw)),
				_Utils_Tuple2(
				'password',
				$elm$json$Json$Encode$string(user.R))
			]));
};
var $elm$http$Http$post = function (r) {
	return $elm$http$Http$request(
		{z: r.z, W: r.W, ah: _List_Nil, aj: 'POST', an: $elm$core$Maybe$Nothing, ap: $elm$core$Maybe$Nothing, ab: r.ab});
};
var $author$project$Auth$User = function (email) {
	return function (token) {
		return function (username) {
			return function (bio) {
				return function (image) {
					return function (password) {
						return function (signedUpOrloggedIn) {
							return function (errmsg) {
								return function (usernameError) {
									return function (emailError) {
										return function (passwordError) {
											return {aH: bio, bw: email, au: emailError, aS: errmsg, O: image, R: password, ay: passwordError, be: signedUpOrloggedIn, T: token, j: username, aB: usernameError};
										};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded = A2($elm$core$Basics$composeR, $elm$json$Json$Decode$succeed, $NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$custom);
var $author$project$Auth$userDecoder = A2(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
	$elm$core$Maybe$Just(''),
	A2(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
		$elm$core$Maybe$Just(''),
		A2(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
			$elm$core$Maybe$Just(''),
			A2(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
				'',
				A2(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
					true,
					A2(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$hardcoded,
						'',
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'image',
							$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'bio',
								$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'username',
									$elm$json$Json$Decode$string,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'token',
										$elm$json$Json$Decode$string,
										A3(
											$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
											'email',
											$elm$json$Json$Decode$string,
											$elm$json$Json$Decode$succeed($author$project$Auth$User))))))))))));
var $author$project$Auth$saveUser = function (user) {
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'user',
					$author$project$Auth$encodeUser(user))
				])));
	return $elm$http$Http$post(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Auth$SignedUpGoHome,
				A2($elm$json$Json$Decode$field, 'user', $author$project$Auth$userDecoder)),
			ab: $author$project$Auth$baseUrl + 'api/users'
		});
};
var $elm$core$String$filter = _String_filter;
var $author$project$Auth$isWhiteSpace = function (c) {
	return (c === ' ') || ((c === '\t') || (c === '\n'));
};
var $elm$core$Basics$not = _Basics_not;
var $author$project$Auth$trimString = function (inputString) {
	return A2(
		$elm$core$String$filter,
		A2($elm$core$Basics$composeL, $elm$core$Basics$not, $author$project$Auth$isWhiteSpace),
		inputString);
};
var $elm$regex$Regex$Match = F4(
	function (match, index, number, submatches) {
		return {cL: index, cQ: match, c1: number, dg: submatches};
	});
var $elm$regex$Regex$contains = _Regex_contains;
var $elm$regex$Regex$fromStringWith = _Regex_fromStringWith;
var $elm$regex$Regex$fromString = function (string) {
	return A2(
		$elm$regex$Regex$fromStringWith,
		{cw: false, cT: false},
		string);
};
var $author$project$Auth$validateEmail = function (email) {
	if ($elm$core$String$isEmpty(email)) {
		return $elm$core$Maybe$Just('Email is required');
	} else {
		var emailRegexResult = $elm$regex$Regex$fromString('[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}');
		if (!emailRegexResult.$) {
			var emailRegex = emailRegexResult.a;
			return (!A2($elm$regex$Regex$contains, emailRegex, email)) ? $elm$core$Maybe$Just('Invalid Email Format') : $elm$core$Maybe$Nothing;
		} else {
			return $elm$core$Maybe$Just('Invalid email pattern');
		}
	}
};
var $author$project$Auth$validatePassword = function (pswd) {
	return $elm$core$String$isEmpty(pswd) ? $elm$core$Maybe$Just('Password is required') : (($elm$core$String$length(
		$author$project$Auth$trimString(pswd)) < 6) ? $elm$core$Maybe$Just('Password must be at least 6 characters long') : $elm$core$Maybe$Nothing);
};
var $author$project$Auth$validateUsername = function (username) {
	return $elm$core$String$isEmpty(username) ? $elm$core$Maybe$Just('Username is required') : $elm$core$Maybe$Nothing;
};
var $author$project$Auth$update = F2(
	function (message, user) {
		switch (message.$) {
			case 0:
				var username = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						user,
						{
							j: username,
							aB: $author$project$Auth$validateUsername(username)
						}),
					$elm$core$Platform$Cmd$none);
			case 1:
				var email = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						user,
						{
							bw: email,
							au: $author$project$Auth$validateEmail(email)
						}),
					$elm$core$Platform$Cmd$none);
			case 2:
				var password = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						user,
						{
							R: password,
							ay: $author$project$Auth$validatePassword(password)
						}),
					$elm$core$Platform$Cmd$none);
			case 3:
				var trimmedUser = _Utils_update(
					user,
					{
						bw: $author$project$Auth$trimString(user.bw),
						R: $author$project$Auth$trimString(user.R)
					});
				var validatedUser = _Utils_update(
					trimmedUser,
					{
						au: $author$project$Auth$validateEmail(trimmedUser.bw),
						ay: $author$project$Auth$validatePassword(trimmedUser.R),
						aB: $author$project$Auth$validateUsername(
							$author$project$Auth$trimString(user.j))
					});
				return $author$project$Auth$isFormValid(validatedUser) ? _Utils_Tuple2(
					validatedUser,
					$author$project$Auth$saveUser(validatedUser)) : _Utils_Tuple2(validatedUser, $elm$core$Platform$Cmd$none);
			default:
				if (!message.a.$) {
					var gotUser = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							gotUser,
							{aS: '', R: '', be: true}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(user, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Editor$isFormValid = function (model) {
	return (A2($elm$core$Maybe$withDefault, '', model.ao) === '') && ((A2($elm$core$Maybe$withDefault, '', model.ad) === '') && (A2($elm$core$Maybe$withDefault, '', model.af) === ''));
};
var $author$project$Editor$GotArticle = function (a) {
	return {$: 5, a: a};
};
var $author$project$Editor$Article = function (slug) {
	return function (title) {
		return function (description) {
			return function (body) {
				return function (tagList) {
					return function (createdAt) {
						return function (updatedAt) {
							return function (favorited) {
								return function (favoritesCount) {
									return function (author) {
										return {h: author, z: body, ae: createdAt, bu: description, aJ: favorited, a5: favoritesCount, J: slug, cf: tagList, bi: title, a2: updatedAt};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Editor$articleDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'author',
	$author$project$Editor$authorDecoder,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'favoritesCount',
		$elm$json$Json$Decode$int,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'favorited',
			$elm$json$Json$Decode$bool,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'updatedAt',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'createdAt',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tagList',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'body',
							$elm$json$Json$Decode$string,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'description',
								$elm$json$Json$Decode$string,
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'title',
									$elm$json$Json$Decode$string,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'slug',
										$elm$json$Json$Decode$string,
										$elm$json$Json$Decode$succeed($author$project$Editor$Article)))))))))));
var $author$project$Editor$baseUrl = 'https://api.realworld.io/';
var $elm$json$Json$Encode$list = F2(
	function (func, entries) {
		return _Json_wrap(
			A3(
				$elm$core$List$foldl,
				_Json_addEntry(func),
				_Json_emptyArray(0),
				entries));
	});
var $author$project$Editor$encodeArticle = function (article) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(article.bi)),
				_Utils_Tuple2(
				'description',
				$elm$json$Json$Encode$string(article.bu)),
				_Utils_Tuple2(
				'body',
				$elm$json$Json$Encode$string(article.z)),
				_Utils_Tuple2(
				'tagList',
				A2($elm$json$Json$Encode$list, $elm$json$Json$Encode$string, article.cf))
			]));
};
var $author$project$Editor$saveArticle = function (model) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
		]);
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'article',
					$author$project$Editor$encodeArticle(model.d))
				])));
	return $elm$http$Http$request(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Editor$GotArticle,
				A2($elm$json$Json$Decode$field, 'article', $author$project$Editor$articleDecoder)),
			ah: headers,
			aj: 'POST',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Editor$baseUrl + 'api/articles'
		});
};
var $author$project$Editor$encodeArticleUpdate = function (article) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'title',
				$elm$json$Json$Encode$string(article.bi)),
				_Utils_Tuple2(
				'description',
				$elm$json$Json$Encode$string(article.bu)),
				_Utils_Tuple2(
				'body',
				$elm$json$Json$Encode$string(article.z))
			]));
};
var $author$project$Editor$updateArticle = function (model) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
		]);
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'article',
					$author$project$Editor$encodeArticleUpdate(model.d))
				])));
	return $elm$http$Http$request(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Editor$GotArticle,
				A2($elm$json$Json$Decode$field, 'article', $author$project$Editor$articleDecoder)),
			ah: headers,
			aj: 'PUT',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Editor$baseUrl + ('api/articles/' + model.d.J)
		});
};
var $author$project$Editor$updateBody = F2(
	function (article, newBody) {
		return _Utils_update(
			article,
			{z: newBody});
	});
var $author$project$Editor$updateDescription = F2(
	function (article, newDescription) {
		return _Utils_update(
			article,
			{bu: newDescription});
	});
var $author$project$Editor$updateTags = F2(
	function (article, newTags) {
		return _Utils_update(
			article,
			{cf: newTags});
	});
var $author$project$Editor$updateTitle = F2(
	function (article, newTitle) {
		return _Utils_update(
			article,
			{bi: newTitle});
	});
var $author$project$Editor$validateBody = function (input) {
	return $elm$core$String$isEmpty(input) ? $elm$core$Maybe$Just('Input is required') : (($elm$core$String$length(input) < 500) ? $elm$core$Maybe$Just('Article has to be at least 500 characters long') : $elm$core$Maybe$Nothing);
};
var $author$project$Editor$validateTitle = function (input) {
	return $elm$core$String$isEmpty(input) ? $elm$core$Maybe$Just('Input is required') : $elm$core$Maybe$Nothing;
};
var $author$project$Editor$update = F2(
	function (message, model) {
		switch (message.$) {
			case 0:
				var title = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							d: A2($author$project$Editor$updateTitle, model.d, title),
							ao: $author$project$Editor$validateTitle(title)
						}),
					$elm$core$Platform$Cmd$none);
			case 1:
				var description = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							d: A2($author$project$Editor$updateDescription, model.d, description),
							af: $author$project$Editor$validateTitle(description)
						}),
					$elm$core$Platform$Cmd$none);
			case 2:
				var body = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							d: A2($author$project$Editor$updateBody, model.d, body),
							ad: $author$project$Editor$validateBody(body)
						}),
					$elm$core$Platform$Cmd$none);
			case 3:
				var tagInput = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{aO: tagInput}),
					$elm$core$Platform$Cmd$none);
			case 4:
				var validatedModel = _Utils_update(
					model,
					{
						ad: $author$project$Editor$validateBody(model.d.z),
						af: $author$project$Editor$validateTitle(model.d.bu),
						ao: $author$project$Editor$validateTitle(model.d.bi)
					});
				var tags = A2(
					$elm$core$List$map,
					$elm$core$String$trim,
					A2($elm$core$String$split, ',', model.aO));
				return $author$project$Editor$isFormValid(validatedModel) ? _Utils_Tuple2(
					_Utils_update(
						validatedModel,
						{
							d: A2($author$project$Editor$updateTags, model.d, tags)
						}),
					$author$project$Editor$saveArticle(validatedModel)) : _Utils_Tuple2(validatedModel, $elm$core$Platform$Cmd$none);
			case 5:
				if (!message.a.$) {
					var gotArticle = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{d: gotArticle}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			default:
				var validatedModel = _Utils_update(
					model,
					{
						ad: $author$project$Editor$validateBody(model.d.z),
						af: $author$project$Editor$validateTitle(model.d.bu),
						ao: $author$project$Editor$validateTitle(model.d.bi)
					});
				return $author$project$Editor$isFormValid(validatedModel) ? _Utils_Tuple2(
					validatedModel,
					$author$project$Editor$updateArticle(validatedModel)) : _Utils_Tuple2(validatedModel, $elm$core$Platform$Cmd$none);
		}
	});
var $author$project$Index$GotArticleLoadGF = function (a) {
	return {$: 10, a: a};
};
var $author$project$Index$encodeArticle = function (article) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'slug',
				$elm$json$Json$Encode$string(article.J))
			]));
};
var $author$project$Index$favoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Index$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Index$GotArticleLoadGF,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Index$articleDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Auth$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Index$GotArticleLoadYF = function (a) {
	return {$: 11, a: a};
};
var $author$project$Index$favoriteArticleYF = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Index$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Index$GotArticleLoadYF,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Index$articleDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Auth$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Index$GotTagFeed = function (a) {
	return {$: 4, a: a};
};
var $author$project$Index$fetchTagArticles = function (tag) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Index$GotTagFeed,
				A2(
					$elm$json$Json$Decode$field,
					'articles',
					$elm$json$Json$Decode$list($author$project$Index$articleDecoder))),
			ab: $author$project$Auth$baseUrl + ('api/articles?tag=' + tag)
		});
};
var $author$project$Index$GotYourFeed = function (a) {
	return {$: 3, a: a};
};
var $author$project$Index$fetchYourArticles = function (model) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
		]);
	var body = $elm$http$Http$emptyBody;
	return $elm$http$Http$request(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Index$GotYourFeed,
				A2(
					$elm$json$Json$Decode$field,
					'articles',
					$elm$json$Json$Decode$list($author$project$Index$articleDecoder))),
			ah: headers,
			aj: 'GET',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Auth$baseUrl + 'api/articles/feed'
		});
};
var $author$project$Index$unfavoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Index$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Index$GotArticleLoadGF,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Index$articleDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Auth$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Index$unfavoriteArticleYF = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Index$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Index$GotArticleLoadYF,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Index$articleDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Auth$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Index$update = F2(
	function (msg, model) {
		switch (msg.$) {
			case 0:
				var article = msg.a;
				return article.aJ ? _Utils_Tuple2(
					model,
					model.S ? A2($author$project$Index$unfavoriteArticle, model, article) : A2($author$project$Index$unfavoriteArticleYF, model, article)) : _Utils_Tuple2(
					model,
					model.S ? A2($author$project$Index$favoriteArticle, model, article) : A2($author$project$Index$favoriteArticleYF, model, article));
			case 1:
				if (!msg.a.$) {
					var globalfeed = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								aU: $elm$core$Maybe$Just(globalfeed),
								S: true,
								_: false
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 2:
				if (!msg.a.$) {
					var tags = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								a$: $elm$core$Maybe$Just(tags)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 3:
				if (!msg.a.$) {
					var yourfeed = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								S: false,
								_: false,
								a3: $elm$core$Maybe$Just(yourfeed)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 4:
				if (!msg.a.$) {
					var tagfeed = msg.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								S: false,
								_: true,
								a_: $elm$core$Maybe$Just(tagfeed)
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 5:
				return _Utils_Tuple2(model, $author$project$Index$fetchGlobalArticles);
			case 6:
				return _Utils_Tuple2(
					model,
					$author$project$Index$fetchYourArticles(model));
			case 7:
				var tag = msg.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{am: tag}),
					$author$project$Index$fetchTagArticles(tag));
			case 8:
				var slug = msg.a;
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 9:
				var username = msg.a;
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			case 10:
				if (!msg.a.$) {
					var article = msg.a.a;
					return _Utils_Tuple2(model, $author$project$Index$fetchGlobalArticles);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			default:
				if (!msg.a.$) {
					var article = msg.a.a;
					return _Utils_Tuple2(
						model,
						$author$project$Index$fetchYourArticles(model));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Login$isLoginValid = function (user) {
	return (A2($elm$core$Maybe$withDefault, '', user.au) === '') && (A2($elm$core$Maybe$withDefault, '', user.ay) === '');
};
var $author$project$Login$SignedUpGoHome = function (a) {
	return {$: 3, a: a};
};
var $author$project$Login$encodeUserLogin = function (user) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(user.bw)),
				_Utils_Tuple2(
				'password',
				$elm$json$Json$Encode$string(user.R))
			]));
};
var $author$project$Login$saveUserLogin = function (user) {
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'user',
					$author$project$Login$encodeUserLogin(user))
				])));
	return $elm$http$Http$post(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Login$SignedUpGoHome,
				A2($elm$json$Json$Decode$field, 'user', $author$project$Auth$userDecoder)),
			ab: $author$project$Auth$baseUrl + 'api/users/login'
		});
};
var $author$project$Login$update = F2(
	function (message, user) {
		switch (message.$) {
			case 0:
				var email = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						user,
						{bw: email}),
					$elm$core$Platform$Cmd$none);
			case 1:
				var password = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						user,
						{R: password}),
					$elm$core$Platform$Cmd$none);
			case 2:
				var trimmedUser = _Utils_update(
					user,
					{
						bw: $author$project$Auth$trimString(user.bw),
						R: $author$project$Auth$trimString(user.R)
					});
				var validatedUser = _Utils_update(
					trimmedUser,
					{
						au: $author$project$Auth$validateEmail(trimmedUser.bw),
						ay: $author$project$Auth$validatePassword(trimmedUser.R)
					});
				return $author$project$Login$isLoginValid(validatedUser) ? _Utils_Tuple2(
					validatedUser,
					$author$project$Login$saveUserLogin(validatedUser)) : _Utils_Tuple2(validatedUser, $elm$core$Platform$Cmd$none);
			default:
				if (!message.a.$) {
					var gotUser = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							gotUser,
							{aS: '', R: '', be: true}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(user, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Profile$GotArticleLoadArticles = function (a) {
	return {$: 7, a: a};
};
var $author$project$Profile$Article = function (slug) {
	return function (title) {
		return function (description) {
			return function (body) {
				return function (tagList) {
					return function (createdAt) {
						return function (updatedAt) {
							return function (favorited) {
								return function (favoritesCount) {
									return function (author) {
										return {h: author, z: body, ae: createdAt, bu: description, aJ: favorited, a5: favoritesCount, J: slug, cf: tagList, bi: title, a2: updatedAt};
									};
								};
							};
						};
					};
				};
			};
		};
	};
};
var $author$project$Profile$articleDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'author',
	$author$project$Profile$profileDecoder,
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'favoritesCount',
		$elm$json$Json$Decode$int,
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'favorited',
			$elm$json$Json$Decode$bool,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'updatedAt',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'createdAt',
					$elm$json$Json$Decode$string,
					A3(
						$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
						'tagList',
						$elm$json$Json$Decode$list($elm$json$Json$Decode$string),
						A3(
							$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
							'body',
							$elm$json$Json$Decode$string,
							A3(
								$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
								'description',
								$elm$json$Json$Decode$string,
								A3(
									$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
									'title',
									$elm$json$Json$Decode$string,
									A3(
										$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
										'slug',
										$elm$json$Json$Decode$string,
										$elm$json$Json$Decode$succeed($author$project$Profile$Article)))))))))));
var $author$project$Profile$baseUrl = 'https://api.realworld.io/';
var $author$project$Profile$encodeArticle = function (article) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'slug',
				$elm$json$Json$Encode$string(article.J))
			]));
};
var $author$project$Profile$favoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Profile$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotArticleLoadArticles,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Profile$articleDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Profile$GotArticleLoadFavArticles = function (a) {
	return {$: 8, a: a};
};
var $author$project$Profile$favoriteArticleYF = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Profile$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotArticleLoadFavArticles,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Profile$articleDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Profile$GotFavoritedArticles = function (a) {
	return {$: 4, a: a};
};
var $author$project$Profile$fetchFavoritedArticles = function (username) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Profile$GotFavoritedArticles,
				A2(
					$elm$json$Json$Decode$field,
					'articles',
					$elm$json$Json$Decode$list($author$project$Profile$articleDecoder))),
			ab: $author$project$Profile$baseUrl + ('api/articles?favorited=' + username)
		});
};
var $author$project$Profile$GotProfileArticles = function (a) {
	return {$: 3, a: a};
};
var $author$project$Profile$fetchProfileArticles = function (username) {
	return $elm$http$Http$get(
		{
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Profile$GotProfileArticles,
				A2(
					$elm$json$Json$Decode$field,
					'articles',
					$elm$json$Json$Decode$list($author$project$Profile$articleDecoder))),
			ab: $author$project$Profile$baseUrl + ('api/articles?author=' + username)
		});
};
var $author$project$Profile$GotProfile = function (a) {
	return {$: 2, a: a};
};
var $author$project$Profile$encodeMaybeString = function (maybeString) {
	if (!maybeString.$) {
		var string = maybeString.a;
		return $elm$json$Json$Encode$string(string);
	} else {
		return $elm$json$Json$Encode$null;
	}
};
var $author$project$Profile$encodeProfile = function (profile) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(profile.j)),
				_Utils_Tuple2(
				'bio',
				$author$project$Profile$encodeMaybeString(profile.aH)),
				_Utils_Tuple2(
				'image',
				$author$project$Profile$encodeMaybeString(profile.O))
			]));
};
var $author$project$Profile$followUser = F2(
	function (model, profile) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'profile',
						$author$project$Profile$encodeProfile(profile))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotProfile,
					A2($elm$json$Json$Decode$field, 'profile', $author$project$Profile$profileDecoder)),
				ah: headers,
				aj: 'POST',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/profiles/' + (profile.j + '/follow'))
			});
	});
var $author$project$Profile$unfavoriteArticle = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Profile$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotArticleLoadArticles,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Profile$articleDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Profile$unfavoriteArticleYF = F2(
	function (model, article) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'article',
						$author$project$Profile$encodeArticle(article))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotArticleLoadFavArticles,
					A2($elm$json$Json$Decode$field, 'article', $author$project$Profile$articleDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/articles/' + (article.J + '/favorite'))
			});
	});
var $author$project$Profile$unfollowUser = F2(
	function (model, profile) {
		var headers = _List_fromArray(
			[
				A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
			]);
		var body = $elm$http$Http$jsonBody(
			$elm$json$Json$Encode$object(
				_List_fromArray(
					[
						_Utils_Tuple2(
						'profile',
						$author$project$Profile$encodeProfile(profile))
					])));
		return $elm$http$Http$request(
			{
				z: body,
				W: A2(
					$elm$http$Http$expectJson,
					$author$project$Profile$GotProfile,
					A2($elm$json$Json$Decode$field, 'profile', $author$project$Profile$profileDecoder)),
				ah: headers,
				aj: 'DELETE',
				an: $elm$core$Maybe$Nothing,
				ap: $elm$core$Maybe$Nothing,
				ab: $author$project$Profile$baseUrl + ('api/profiles/' + (profile.j + '/follow'))
			});
	});
var $author$project$Profile$update = F2(
	function (message, model) {
		switch (message.$) {
			case 0:
				var article = message.a;
				return article.aJ ? _Utils_Tuple2(
					model,
					model.az ? A2($author$project$Profile$unfavoriteArticle, model, article) : A2($author$project$Profile$unfavoriteArticleYF, model, article)) : _Utils_Tuple2(
					model,
					model.az ? A2($author$project$Profile$favoriteArticle, model, article) : A2($author$project$Profile$favoriteArticleYF, model, article));
			case 1:
				return model.x.aK ? _Utils_Tuple2(
					model,
					A2($author$project$Profile$unfollowUser, model, model.x)) : _Utils_Tuple2(
					model,
					A2($author$project$Profile$followUser, model, model.x));
			case 2:
				if (!message.a.$) {
					var userProfile = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{x: userProfile}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 3:
				if (!message.a.$) {
					var articlesMade = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								E: $elm$core$Maybe$Just(articlesMade),
								az: true
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 4:
				if (!message.a.$) {
					var favoritedArticles = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{
								aw: $elm$core$Maybe$Just(favoritedArticles),
								az: false
							}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			case 5:
				var profile = message.a;
				return _Utils_Tuple2(
					model,
					$author$project$Profile$fetchProfileArticles(profile));
			case 6:
				var profile = message.a;
				return _Utils_Tuple2(
					model,
					$author$project$Profile$fetchFavoritedArticles(profile));
			case 7:
				if (!message.a.$) {
					var article = message.a.a;
					return _Utils_Tuple2(
						model,
						$author$project$Profile$fetchProfileArticles(model.x.j));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
			default:
				if (!message.a.$) {
					var article = message.a.a;
					return _Utils_Tuple2(
						model,
						$author$project$Profile$fetchFavoritedArticles(model.x.j));
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Settings$isFormValid = function (model) {
	return (A2($elm$core$Maybe$withDefault, '', model.aB) === '') && (A2($elm$core$Maybe$withDefault, '', model.au) === '');
};
var $author$project$Settings$trimEmail = F2(
	function (user, trimmedEmail) {
		return _Utils_update(
			user,
			{bw: trimmedEmail});
	});
var $author$project$Settings$updateBio = F2(
	function (user, newBio) {
		return _Utils_update(
			user,
			{
				aH: $elm$core$Maybe$Just(newBio)
			});
	});
var $author$project$Settings$updateEmail = F2(
	function (user, newEmail) {
		return _Utils_update(
			user,
			{bw: newEmail});
	});
var $author$project$Settings$updateImage = F2(
	function (user, newImage) {
		return _Utils_update(
			user,
			{
				O: $elm$core$Maybe$Just(newImage)
			});
	});
var $author$project$Settings$GotUser = function (a) {
	return {$: 6, a: a};
};
var $author$project$Settings$baseUrl = 'https://api.realworld.io/';
var $author$project$Settings$encodeMaybeString = function (maybeString) {
	if (!maybeString.$) {
		var string = maybeString.a;
		return $elm$json$Json$Encode$string(string);
	} else {
		return $elm$json$Json$Encode$null;
	}
};
var $author$project$Settings$encodeUser = function (model) {
	return $elm$json$Json$Encode$object(
		_List_fromArray(
			[
				_Utils_Tuple2(
				'email',
				$elm$json$Json$Encode$string(model.D.bw)),
				_Utils_Tuple2(
				'password',
				$elm$json$Json$Encode$string(model.R)),
				_Utils_Tuple2(
				'username',
				$elm$json$Json$Encode$string(model.D.j)),
				_Utils_Tuple2(
				'bio',
				$author$project$Settings$encodeMaybeString(model.D.aH)),
				_Utils_Tuple2(
				'image',
				$author$project$Settings$encodeMaybeString(model.D.O))
			]));
};
var $author$project$Settings$User = F5(
	function (email, token, username, bio, image) {
		return {aH: bio, bw: email, O: image, T: token, j: username};
	});
var $author$project$Settings$userDecoder = A3(
	$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
	'image',
	$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
	A3(
		$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
		'bio',
		$elm$json$Json$Decode$nullable($elm$json$Json$Decode$string),
		A3(
			$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
			'username',
			$elm$json$Json$Decode$string,
			A3(
				$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
				'token',
				$elm$json$Json$Decode$string,
				A3(
					$NoRedInk$elm_json_decode_pipeline$Json$Decode$Pipeline$required,
					'email',
					$elm$json$Json$Decode$string,
					$elm$json$Json$Decode$succeed($author$project$Settings$User))))));
var $author$project$Settings$updateUser = function (model) {
	var headers = _List_fromArray(
		[
			A2($elm$http$Http$header, 'Authorization', 'Token ' + model.D.T)
		]);
	var body = $elm$http$Http$jsonBody(
		$elm$json$Json$Encode$object(
			_List_fromArray(
				[
					_Utils_Tuple2(
					'user',
					$author$project$Settings$encodeUser(model))
				])));
	return $elm$http$Http$request(
		{
			z: body,
			W: A2(
				$elm$http$Http$expectJson,
				$author$project$Settings$GotUser,
				A2($elm$json$Json$Decode$field, 'user', $author$project$Settings$userDecoder)),
			ah: headers,
			aj: 'PUT',
			an: $elm$core$Maybe$Nothing,
			ap: $elm$core$Maybe$Nothing,
			ab: $author$project$Settings$baseUrl + 'api/user'
		});
};
var $author$project$Settings$updateUsername = F2(
	function (user, newUsername) {
		return _Utils_update(
			user,
			{j: newUsername});
	});
var $author$project$Settings$update = F2(
	function (message, model) {
		switch (message.$) {
			case 0:
				var image = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							D: A2($author$project$Settings$updateImage, model.D, image)
						}),
					$elm$core$Platform$Cmd$none);
			case 1:
				var username = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							D: A2($author$project$Settings$updateUsername, model.D, username)
						}),
					$elm$core$Platform$Cmd$none);
			case 2:
				var bio = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							D: A2($author$project$Settings$updateBio, model.D, bio)
						}),
					$elm$core$Platform$Cmd$none);
			case 3:
				var email = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{
							D: A2($author$project$Settings$updateEmail, model.D, email)
						}),
					$elm$core$Platform$Cmd$none);
			case 4:
				var password = message.a;
				return _Utils_Tuple2(
					_Utils_update(
						model,
						{R: password}),
					$elm$core$Platform$Cmd$none);
			case 5:
				var trimmedModel = _Utils_update(
					model,
					{
						R: $author$project$Auth$trimString(model.R),
						D: A2(
							$author$project$Settings$trimEmail,
							model.D,
							$author$project$Auth$trimString(model.D.bw))
					});
				var validatedModel = _Utils_update(
					trimmedModel,
					{
						au: $author$project$Auth$validateEmail(trimmedModel.D.bw),
						ay: $author$project$Auth$validatePassword(trimmedModel.R),
						aB: $author$project$Auth$validateUsername(trimmedModel.D.j)
					});
				return $author$project$Settings$isFormValid(validatedModel) ? _Utils_Tuple2(
					validatedModel,
					$author$project$Settings$updateUser(validatedModel)) : _Utils_Tuple2(validatedModel, $elm$core$Platform$Cmd$none);
			case 7:
				return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
			default:
				if (!message.a.$) {
					var gotUser = message.a.a;
					return _Utils_Tuple2(
						_Utils_update(
							model,
							{aS: '', R: '', dm: true, D: gotUser}),
						$elm$core$Platform$Cmd$none);
				} else {
					return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
				}
		}
	});
var $author$project$Main$update = F2(
	function (msg, model) {
		var _v0 = _Utils_Tuple2(msg, model.e);
		_v0$23:
		while (true) {
			_v0$25:
			while (true) {
				switch (_v0.a.$) {
					case 0:
						var maybeRoute = _v0.a.a;
						return A2($author$project$Main$setNewPage, maybeRoute, model);
					case 11:
						if (!_v0.a.a.$) {
							var article = _v0.a.a.a;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										d: article,
										e: $author$project$Main$Editor(
											{
												d: article,
												ad: $elm$core$Maybe$Just(''),
												br: false,
												af: $elm$core$Maybe$Just(''),
												aO: A2($elm$core$String$join, ',', article.cf),
												ao: $elm$core$Maybe$Just(''),
												D: model.D
											})
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						}
					case 9:
						if (!_v0.a.a.$) {
							var profile = _v0.a.a.a;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Profile(
											{E: model.E, aw: $elm$core$Maybe$Nothing, x: profile, az: true, D: model.D}),
										x: profile
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Profile(
											{E: model.E, aw: $elm$core$Maybe$Nothing, x: $author$project$Main$defaultProfile, az: true, D: model.D}),
										x: $author$project$Main$defaultProfile
									}),
								$elm$core$Platform$Cmd$none);
						}
					case 10:
						if (!_v0.a.a.$) {
							var user = _v0.a.a.a;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Settings(
											{
												au: $elm$core$Maybe$Just(''),
												aS: '',
												R: '',
												ay: $elm$core$Maybe$Just(''),
												dm: false,
												D: user,
												aB: $elm$core$Maybe$Just('')
											})
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{m: 'Home'}),
								$elm$core$Platform$Cmd$none);
						}
					case 12:
						var result = _v0.a.a;
						if (!result.$) {
							var _v2 = result.a;
							var article = _v2.a;
							var comments = _v2.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										d: article,
										as: $elm$core$Maybe$Just(comments),
										e: $author$project$Main$Article(
											{
												d: article,
												as: $elm$core$Maybe$Just(comments),
												Q: '',
												D: model.D
											})
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							var error = result.a;
							return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
						}
					case 13:
						var result = _v0.a.a;
						if (!result.$) {
							var _v4 = result.a;
							var profile = _v4.a;
							var articlesMade = _v4.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Profile(
											{
												E: $elm$core$Maybe$Just(articlesMade),
												aw: $elm$core$Maybe$Nothing,
												x: profile,
												az: true,
												D: model.D
											}),
										x: profile
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							var error = result.a;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										E: $elm$core$Maybe$Nothing,
										e: $author$project$Main$Profile(
											{E: $elm$core$Maybe$Nothing, aw: $elm$core$Maybe$Nothing, x: $author$project$Main$defaultProfile, az: true, D: model.D}),
										x: $author$project$Main$defaultProfile
									}),
								$elm$core$Platform$Cmd$none);
						}
					case 14:
						var result = _v0.a.a;
						if (!result.$) {
							var _v6 = result.a;
							var profile = _v6.a;
							var favoritedArticles = _v6.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Profile(
											{
												E: $elm$core$Maybe$Nothing,
												aw: $elm$core$Maybe$Just(favoritedArticles),
												x: profile,
												az: false,
												D: model.D
											}),
										x: profile
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							var error = result.a;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										E: $elm$core$Maybe$Nothing,
										e: $author$project$Main$Profile(
											{E: $elm$core$Maybe$Nothing, aw: $elm$core$Maybe$Nothing, x: $author$project$Main$defaultProfile, az: false, D: model.D}),
										x: $author$project$Main$defaultProfile
									}),
								$elm$core$Platform$Cmd$none);
						}
					case 15:
						var result = _v0.a.a;
						if (!result.$) {
							var _v8 = result.a;
							var globalfeed = _v8.a;
							var tags = _v8.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$PublicFeed(
											{
												aU: $elm$core$Maybe$Just(globalfeed),
												S: true,
												_: false,
												am: '',
												a_: $elm$core$Maybe$Nothing,
												a$: $elm$core$Maybe$Just(tags),
												D: model.D,
												a3: $elm$core$Maybe$Nothing
											})
									}),
								$elm$core$Platform$Cmd$none);
						} else {
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$PublicFeed(
											{aU: $elm$core$Maybe$Nothing, S: true, _: false, am: '', a_: $elm$core$Maybe$Nothing, a$: $elm$core$Maybe$Nothing, D: model.D, a3: $elm$core$Maybe$Nothing})
									}),
								$elm$core$Platform$Cmd$none);
						}
					case 2:
						if (!_v0.b.$) {
							var publicFeedMsg = _v0.a.a;
							var publicFeedModel = _v0.b.a;
							var _v9 = A2($author$project$Index$update, publicFeedMsg, publicFeedModel);
							var updatedPublicFeedModel = _v9.a;
							var publicFeedCmd = _v9.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										m: 'Home',
										e: $author$project$Main$PublicFeed(updatedPublicFeedModel)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$PublicFeedMessage, publicFeedCmd));
						} else {
							break _v0$25;
						}
					case 3:
						if ((_v0.a.a.$ === 4) && (!_v0.a.a.a.$)) {
							var gotUser = _v0.a.a.a.a;
							var _v10 = $author$project$Index$init;
							var publicFeedModel = _v10.a;
							var publicFeedCmd = _v10.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										m: 'Home',
										ax: true,
										e: $author$project$Main$PublicFeed(
											_Utils_update(
												publicFeedModel,
												{
													D: $author$project$Main$convertUser(gotUser)
												})),
										D: $author$project$Main$convertUser(gotUser)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$PublicFeedMessage, publicFeedCmd));
						} else {
							if (_v0.b.$ === 1) {
								var authMsg = _v0.a.a;
								var authUser = _v0.b.a;
								var _v11 = A2($author$project$Auth$update, authMsg, authUser);
								var updatedAuthUser = _v11.a;
								var authCmd = _v11.b;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											e: $author$project$Main$Auth(updatedAuthUser)
										}),
									A2($elm$core$Platform$Cmd$map, $author$project$Main$AuthMessage, authCmd));
							} else {
								break _v0$25;
							}
						}
					case 4:
						if ((_v0.a.a.$ === 5) && (!_v0.a.a.a.$)) {
							var gotArticle = _v0.a.a.a.a;
							var _v12 = $author$project$Article$init;
							var articleModel = _v12.a;
							var articleCmd = _v12.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Article(
											{d: gotArticle, as: $elm$core$Maybe$Nothing, Q: '', D: model.D})
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$ArticleMessage, articleCmd));
						} else {
							if (_v0.b.$ === 2) {
								var editorMsg = _v0.a.a;
								var editorArticle = _v0.b.a;
								var _v13 = A2($author$project$Editor$update, editorMsg, editorArticle);
								var updatedEditorArticle = _v13.a;
								var editorCmd = _v13.b;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											e: $author$project$Main$Editor(updatedEditorArticle)
										}),
									A2($elm$core$Platform$Cmd$map, $author$project$Main$EditorMessage, editorCmd));
							} else {
								break _v0$25;
							}
						}
					case 5:
						if ((_v0.a.a.$ === 3) && (!_v0.a.a.a.$)) {
							var gotUser = _v0.a.a.a.a;
							var _v14 = $author$project$Index$init;
							var publicFeedModel = _v14.a;
							var publicFeedCmd = _v14.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										m: 'Home',
										ax: true,
										e: $author$project$Main$PublicFeed(
											_Utils_update(
												publicFeedModel,
												{
													D: $author$project$Main$convertUser(gotUser)
												})),
										D: $author$project$Main$convertUser(gotUser)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$PublicFeedMessage, publicFeedCmd));
						} else {
							if (_v0.b.$ === 3) {
								var loginMsg = _v0.a.a;
								var loginUser = _v0.b.a;
								var _v15 = A2($author$project$Login$update, loginMsg, loginUser);
								var updatedLoginUser = _v15.a;
								var loginCmd = _v15.b;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											e: $author$project$Main$Login(updatedLoginUser)
										}),
									A2($elm$core$Platform$Cmd$map, $author$project$Main$LoginMessage, loginCmd));
							} else {
								break _v0$25;
							}
						}
					case 6:
						if (_v0.a.a.$ === 12) {
							var _v16 = $author$project$Index$init;
							var publicFeedModel = _v16.a;
							var publicFeedCmd = _v16.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										m: 'Home',
										e: $author$project$Main$PublicFeed(publicFeedModel)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$PublicFeedMessage, publicFeedCmd));
						} else {
							if (_v0.b.$ === 4) {
								var articleMsg = _v0.a.a;
								var articleModel = _v0.b.a;
								var _v17 = A2($author$project$Article$update, articleMsg, articleModel);
								var updatedArticleModel = _v17.a;
								var articleCmd = _v17.b;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											e: $author$project$Main$Article(updatedArticleModel)
										}),
									A2($elm$core$Platform$Cmd$map, $author$project$Main$ArticleMessage, articleCmd));
							} else {
								break _v0$25;
							}
						}
					case 7:
						if (_v0.b.$ === 5) {
							var profileMsg = _v0.a.a;
							var profileModel = _v0.b.a;
							var _v18 = A2($author$project$Profile$update, profileMsg, profileModel);
							var updatedProfileModel = _v18.a;
							var profileCmd = _v18.b;
							return _Utils_Tuple2(
								_Utils_update(
									model,
									{
										e: $author$project$Main$Profile(updatedProfileModel)
									}),
								A2($elm$core$Platform$Cmd$map, $author$project$Main$ProfileMessage, profileCmd));
						} else {
							break _v0$25;
						}
					case 8:
						switch (_v0.a.a.$) {
							case 7:
								var _v19 = _v0.a.a;
								var _v20 = $author$project$Index$init;
								var publicFeedModel = _v20.a;
								var publicFeedCmd = _v20.b;
								return _Utils_Tuple2(
									_Utils_update(
										model,
										{
											m: 'Home',
											ax: false,
											e: $author$project$Main$PublicFeed(publicFeedModel),
											D: $author$project$Main$defaultUser
										}),
									A2($elm$core$Platform$Cmd$map, $author$project$Main$PublicFeedMessage, publicFeedCmd));
							case 6:
								if (!_v0.a.a.a.$) {
									var gotUser = _v0.a.a.a.a;
									var _v21 = $author$project$Profile$init;
									var initProfileModel = _v21.a;
									var profileCmd = _v21.b;
									return _Utils_Tuple2(
										_Utils_update(
											model,
											{
												e: $author$project$Main$Profile(initProfileModel),
												D: gotUser
											}),
										$author$project$Main$fetchProfile(gotUser.j));
								} else {
									if (_v0.b.$ === 6) {
										break _v0$23;
									} else {
										break _v0$25;
									}
								}
							default:
								if (_v0.b.$ === 6) {
									break _v0$23;
								} else {
									break _v0$25;
								}
						}
					default:
						var urlRequest = _v0.a.a;
						if (!urlRequest.$) {
							var url = urlRequest.a;
							return _Utils_Tuple2(
								model,
								A2(
									$elm$browser$Browser$Navigation$pushUrl,
									model.a9,
									$elm$url$Url$toString(url)));
						} else {
							var url = urlRequest.a;
							return _Utils_Tuple2(
								model,
								$elm$browser$Browser$Navigation$load(url));
						}
				}
			}
			return _Utils_Tuple2(model, $elm$core$Platform$Cmd$none);
		}
		var settingsMsg = _v0.a.a;
		var settingsUserSettings = _v0.b.a;
		var _v22 = A2($author$project$Settings$update, settingsMsg, settingsUserSettings);
		var updatedSettingsUserSettings = _v22.a;
		var settingsCmd = _v22.b;
		return _Utils_Tuple2(
			_Utils_update(
				model,
				{
					e: $author$project$Main$Settings(updatedSettingsUserSettings)
				}),
			A2($elm$core$Platform$Cmd$map, $author$project$Main$SettingsMessage, settingsCmd));
	});
var $elm$html$Html$Attributes$stringProperty = F2(
	function (key, string) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$string(string));
	});
var $elm$html$Html$Attributes$class = $elm$html$Html$Attributes$stringProperty('className');
var $elm$html$Html$div = _VirtualDom_node('div');
var $elm$html$Html$h1 = _VirtualDom_node('h1');
var $elm$virtual_dom$VirtualDom$map = _VirtualDom_map;
var $elm$html$Html$map = $elm$virtual_dom$VirtualDom$map;
var $elm$virtual_dom$VirtualDom$text = _VirtualDom_text;
var $elm$html$Html$text = $elm$virtual_dom$VirtualDom$text;
var $elm$html$Html$a = _VirtualDom_node('a');
var $elm$html$Html$footer = _VirtualDom_node('footer');
var $author$project$Article$monthName = function (month) {
	switch (month) {
		case '01':
			return 'January';
		case '02':
			return 'February';
		case '03':
			return 'March';
		case '04':
			return 'April';
		case '05':
			return 'May';
		case '06':
			return 'June';
		case '07':
			return 'July';
		case '08':
			return 'August';
		case '09':
			return 'September';
		case '10':
			return 'October';
		case '11':
			return 'November';
		case '12':
			return 'December';
		default:
			return 'Invalid month';
	}
};
var $author$project$Article$splitDate = function (dateStr) {
	var parts = A2($elm$core$String$split, '-', dateStr);
	if (((parts.b && parts.b.b) && parts.b.b.b) && (!parts.b.b.b.b)) {
		var year = parts.a;
		var _v1 = parts.b;
		var month = _v1.a;
		var _v2 = _v1.b;
		var dayWithTime = _v2.a;
		var day = A2($elm$core$String$left, 2, dayWithTime);
		return $elm$core$Maybe$Just(
			_Utils_Tuple3(year, month, day));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Article$formatDate = function (dateStr) {
	var _v0 = $author$project$Article$splitDate(dateStr);
	if (!_v0.$) {
		var _v1 = _v0.a;
		var year = _v1.a;
		var month = _v1.b;
		var day = _v1.c;
		return $author$project$Article$monthName(month) + (' ' + (day + (', ' + year)));
	} else {
		return 'Invalid date';
	}
};
var $elm$html$Html$Attributes$href = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'href',
		_VirtualDom_noJavaScriptUri(url));
};
var $author$project$Routes$routeToUrl = function (route) {
	switch (route.$) {
		case 0:
			return '#/';
		case 1:
			return '#/register';
		case 2:
			return '#/editor';
		case 3:
			var slug = route.a;
			return '#/editor/' + slug;
		case 4:
			return '#/login';
		case 5:
			var slug = route.a;
			return '#/article/' + slug;
		case 6:
			if (route.b === 1) {
				var username = route.a;
				var _v1 = route.b;
				return '#/profile/' + username;
			} else {
				var username = route.a;
				var _v2 = route.b;
				return '#/profile/' + (username + '/favorites');
			}
		default:
			return '#/settings';
	}
};
var $author$project$Routes$href = function (route) {
	return $elm$html$Html$Attributes$href(
		$author$project$Routes$routeToUrl(route));
};
var $elm$html$Html$img = _VirtualDom_node('img');
var $author$project$Article$maybeImageBio = function (maybeIB) {
	if (!maybeIB.$) {
		var imagebio = maybeIB.a;
		return imagebio;
	} else {
		return '';
	}
};
var $elm$html$Html$span = _VirtualDom_node('span');
var $elm$html$Html$Attributes$src = function (url) {
	return A2(
		$elm$html$Html$Attributes$stringProperty,
		'src',
		_VirtualDom_noJavaScriptOrHtmlUri(url));
};
var $elm$html$Html$hr = _VirtualDom_node('hr');
var $elm$html$Html$p = _VirtualDom_node('p');
var $author$project$Article$SaveComment = function (a) {
	return {$: 3, a: a};
};
var $author$project$Article$UpdateComment = function (a) {
	return {$: 2, a: a};
};
var $elm$html$Html$button = _VirtualDom_node('button');
var $elm$json$Json$Encode$bool = _Json_wrap;
var $elm$html$Html$Attributes$boolProperty = F2(
	function (key, bool) {
		return A2(
			_VirtualDom_property,
			key,
			$elm$json$Json$Encode$bool(bool));
	});
var $elm$html$Html$Attributes$disabled = $elm$html$Html$Attributes$boolProperty('disabled');
var $elm$html$Html$form = _VirtualDom_node('form');
var $elm$virtual_dom$VirtualDom$Normal = function (a) {
	return {$: 0, a: a};
};
var $elm$virtual_dom$VirtualDom$on = _VirtualDom_on;
var $elm$html$Html$Events$on = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$Normal(decoder));
	});
var $elm$html$Html$Events$onClick = function (msg) {
	return A2(
		$elm$html$Html$Events$on,
		'click',
		$elm$json$Json$Decode$succeed(msg));
};
var $elm$html$Html$Events$alwaysStop = function (x) {
	return _Utils_Tuple2(x, true);
};
var $elm$virtual_dom$VirtualDom$MayStopPropagation = function (a) {
	return {$: 1, a: a};
};
var $elm$html$Html$Events$stopPropagationOn = F2(
	function (event, decoder) {
		return A2(
			$elm$virtual_dom$VirtualDom$on,
			event,
			$elm$virtual_dom$VirtualDom$MayStopPropagation(decoder));
	});
var $elm$json$Json$Decode$at = F2(
	function (fields, decoder) {
		return A3($elm$core$List$foldr, $elm$json$Json$Decode$field, decoder, fields);
	});
var $elm$html$Html$Events$targetValue = A2(
	$elm$json$Json$Decode$at,
	_List_fromArray(
		['target', 'value']),
	$elm$json$Json$Decode$string);
var $elm$html$Html$Events$onInput = function (tagger) {
	return A2(
		$elm$html$Html$Events$stopPropagationOn,
		'input',
		A2(
			$elm$json$Json$Decode$map,
			$elm$html$Html$Events$alwaysStop,
			A2($elm$json$Json$Decode$map, tagger, $elm$html$Html$Events$targetValue)));
};
var $elm$html$Html$Attributes$placeholder = $elm$html$Html$Attributes$stringProperty('placeholder');
var $elm$html$Html$Attributes$rows = function (n) {
	return A2(
		_VirtualDom_attribute,
		'rows',
		$elm$core$String$fromInt(n));
};
var $elm$html$Html$textarea = _VirtualDom_node('textarea');
var $elm$html$Html$Attributes$type_ = $elm$html$Html$Attributes$stringProperty('type');
var $elm$html$Html$Attributes$value = $elm$html$Html$Attributes$stringProperty('value');
var $author$project$Article$DeleteComment = function (a) {
	return {$: 4, a: a};
};
var $author$project$Article$FetchProfileArticle = function (a) {
	return {$: 11, a: a};
};
var $elm$html$Html$i = _VirtualDom_node('i');
var $author$project$Article$viewComment = F2(
	function (model, comment) {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('card')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('card-block')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$p,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('card-text')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(comment.z)
								]))
						])),
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('card-footer')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$author$project$Routes$href(
									A2($author$project$Routes$Profile, comment.h.j, 1)),
									$elm$html$Html$Events$onClick(
									$author$project$Article$FetchProfileArticle(comment.h.j)),
									$elm$html$Html$Attributes$class('comment-author')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$img,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$src(
											$author$project$Article$maybeImageBio(comment.h.O)),
											$elm$html$Html$Attributes$class('comment-author-img')
										]),
									_List_Nil)
								])),
							$elm$html$Html$text(' \u00A0 '),
							A2(
							$elm$html$Html$a,
							_List_fromArray(
								[
									$author$project$Routes$href(
									A2($author$project$Routes$Profile, comment.h.j, 1)),
									$elm$html$Html$Events$onClick(
									$author$project$Article$FetchProfileArticle(comment.h.j)),
									$elm$html$Html$Attributes$class('comment-author')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(comment.h.j)
								])),
							$elm$html$Html$text(' '),
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('date-posted')
								]),
							_List_fromArray(
								[
									$elm$html$Html$text(
									$author$project$Article$formatDate(comment.ae))
								])),
							A2(
							$elm$html$Html$span,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('mod-options')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$i,
									_List_fromArray(
										[
											_Utils_eq(model.D.j, comment.h.j) ? $elm$html$Html$Attributes$class('ion-trash-a') : $elm$html$Html$Attributes$class(''),
											$elm$html$Html$Events$onClick(
											$author$project$Article$DeleteComment(comment.a7))
										]),
									_List_Nil)
								]))
						]))
				]));
	});
var $author$project$Article$viewCommentList = F2(
	function (model, maybeComments) {
		if (!maybeComments.$) {
			var comments = maybeComments.a;
			return A2(
				$elm$html$Html$div,
				_List_Nil,
				A2(
					$elm$core$List$map,
					$author$project$Article$viewComment(model),
					comments));
		} else {
			return $elm$html$Html$text('');
		}
	});
var $author$project$Article$viewComments = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('row')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('col-md-8 col-md-offset-2')
					]),
				_List_fromArray(
					[
						A2($author$project$Article$viewCommentList, model, model.as),
						A2(
						$elm$html$Html$form,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('card comment-form')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('card-block')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$textarea,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('form-control'),
												$elm$html$Html$Attributes$placeholder('Write a comment...'),
												$elm$html$Html$Attributes$rows(3),
												$elm$html$Html$Attributes$value(model.Q),
												$elm$html$Html$Events$onInput($author$project$Article$UpdateComment)
											]),
										_List_Nil)
									])),
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('card-footer')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$img,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$src(
												$author$project$Article$maybeImageBio(model.D.O)),
												$elm$html$Html$Attributes$class('comment-author-img')
											]),
										_List_Nil),
										A2(
										$elm$html$Html$button,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('btn btn-sm btn-primary'),
												$elm$html$Html$Attributes$disabled(
												$elm$core$String$isEmpty(model.Q)),
												$elm$html$Html$Attributes$type_('button'),
												$elm$html$Html$Events$onClick(
												$author$project$Article$SaveComment(model.Q))
											]),
										_List_fromArray(
											[
												$elm$html$Html$text(' Post Comment')
											]))
									]))
							]))
					]))
			]));
};
var $author$project$Article$DeleteArticle = {$: 7};
var $author$project$Article$viewEditArticleButtons = function (slug) {
	return A2(
		$elm$html$Html$span,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('ng-scope')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-outline-secondary btn-sm'),
						$author$project$Routes$href(
						$author$project$Routes$Editor(slug))
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('ion-edit')
							]),
						_List_Nil),
						$elm$html$Html$text(' Edit Article ')
					])),
				$elm$html$Html$text(' '),
				A2(
				$elm$html$Html$button,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('btn btn-outline-danger btn-sm'),
						$elm$html$Html$Events$onClick($author$project$Article$DeleteArticle)
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$i,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('ion-trash-a')
							]),
						_List_Nil),
						$elm$html$Html$text(' Delete Article ')
					]))
			]));
};
var $author$project$Article$ToggleFollow = {$: 1};
var $elm$virtual_dom$VirtualDom$style = _VirtualDom_style;
var $elm$html$Html$Attributes$style = $elm$virtual_dom$VirtualDom$style;
var $author$project$Article$viewFollowButton = function (model) {
	var buttonClass = model.d.h.aK ? _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-secondary'),
			A2($elm$html$Html$Attributes$style, 'background-color', 'skyblue'),
			A2($elm$html$Html$Attributes$style, 'color', '#fff'),
			A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Article$ToggleFollow)
		]) : _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-secondary'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Article$ToggleFollow)
		]);
	return A2(
		$elm$html$Html$button,
		buttonClass,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-plus-round')
					]),
				_List_Nil),
				$elm$html$Html$text(
				' \u00A0 ' + ((model.d.h.aK ? 'Unfollow' : 'Follow') + (' ' + (model.d.h.j + ' '))))
			]));
};
var $author$project$Article$ToggleLike = {$: 0};
var $author$project$Article$viewLoveButton = function (model) {
	var buttonClass = model.d.aJ ? _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-primary'),
			A2($elm$html$Html$Attributes$style, 'background-color', '#d00'),
			A2($elm$html$Html$Attributes$style, 'color', '#fff'),
			A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Article$ToggleLike)
		]) : _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-primary'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Article$ToggleLike)
		]);
	return A2(
		$elm$html$Html$button,
		buttonClass,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-heart')
					]),
				_List_Nil),
				$elm$html$Html$text(
				' \u00A0 ' + ((model.d.aJ ? 'Unfavorite' : 'Favorite') + ' Post ')),
				A2(
				$elm$html$Html$span,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('counter')
					]),
				_List_fromArray(
					[
						$elm$html$Html$text(
						'(' + ($elm$core$String$fromInt(model.d.a5) + ')'))
					]))
			]));
};
var $author$project$Article$viewArticle = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('container page')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('row post-content')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('col-md-12')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_Nil,
								_List_fromArray(
									[
										A2(
										$elm$html$Html$p,
										_List_Nil,
										_List_fromArray(
											[
												$elm$html$Html$text(model.d.z)
											]))
									]))
							]))
					])),
				A2($elm$html$Html$hr, _List_Nil, _List_Nil),
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('post-actions')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('post-meta')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href(
										A2($author$project$Routes$Profile, model.d.h.j, 1))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$img,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$src(
												$author$project$Article$maybeImageBio(model.d.h.O))
											]),
										_List_Nil)
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('info')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$author$project$Routes$href(
												A2($author$project$Routes$Profile, model.d.h.j, 1)),
												$elm$html$Html$Attributes$class('author')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text(model.d.h.j)
											])),
										A2(
										$elm$html$Html$span,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('date')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text(
												$author$project$Article$formatDate(model.d.ae))
											]))
									])),
								$elm$html$Html$text(' '),
								_Utils_eq(model.D.j, model.d.h.j) ? $author$project$Article$viewEditArticleButtons(model.d.J) : A2(
								$elm$html$Html$span,
								_List_Nil,
								_List_fromArray(
									[
										$author$project$Article$viewFollowButton(model),
										$elm$html$Html$text('\u00A0'),
										$author$project$Article$viewLoveButton(model)
									]))
							]))
					])),
				$author$project$Article$viewComments(model)
			]));
};
var $author$project$Article$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('post-page')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('banner')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('container')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$h1,
										_List_Nil,
										_List_fromArray(
											[
												$elm$html$Html$text(model.d.bi)
											])),
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('post-meta')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$a,
												_List_fromArray(
													[
														$author$project$Routes$href(
														A2($author$project$Routes$Profile, model.d.h.j, 1))
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$img,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$src(
																$author$project$Article$maybeImageBio(model.d.h.O))
															]),
														_List_Nil)
													])),
												$elm$html$Html$text(' '),
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('info')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$a,
														_List_fromArray(
															[
																$author$project$Routes$href(
																A2($author$project$Routes$Profile, model.d.h.j, 1)),
																$elm$html$Html$Attributes$class('author')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(model.d.h.j)
															])),
														A2(
														$elm$html$Html$span,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('date')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(
																$author$project$Article$formatDate(model.d.ae))
															]))
													])),
												$elm$html$Html$text(' '),
												_Utils_eq(model.D.j, model.d.h.j) ? $author$project$Article$viewEditArticleButtons(model.d.J) : A2(
												$elm$html$Html$span,
												_List_Nil,
												_List_fromArray(
													[
														$author$project$Article$viewFollowButton(model),
														$elm$html$Html$text('\u00A0'),
														$author$project$Article$viewLoveButton(model)
													]))
											]))
									]))
							])),
						$author$project$Article$viewArticle(model)
					])),
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $author$project$Auth$SaveEmail = function (a) {
	return {$: 1, a: a};
};
var $author$project$Auth$SaveName = function (a) {
	return {$: 0, a: a};
};
var $author$project$Auth$SavePassword = function (a) {
	return {$: 2, a: a};
};
var $author$project$Auth$Signup = {$: 3};
var $elm$html$Html$fieldset = _VirtualDom_node('fieldset');
var $elm$html$Html$h3 = _VirtualDom_node('h3');
var $elm$html$Html$Attributes$id = $elm$html$Html$Attributes$stringProperty('id');
var $elm$html$Html$input = _VirtualDom_node('input');
var $author$project$Auth$view = function (user) {
	var mainStuff = function () {
		var loggedIn = ($elm$core$String$length(user.T) > 0) ? true : false;
		var greeting = 'Hello, ' + (user.j + '!');
		return loggedIn ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$id('greeting')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$h3,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('text-center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(greeting)
						])),
					A2(
					$elm$html$Html$p,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('text-center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('You have successfully signed up!')
						]))
				])) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('auth-page')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-6 col-md-offset-3 col-xs-12')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Sign up')
												])),
											A2(
											$elm$html$Html$p,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$a,
													_List_fromArray(
														[
															$author$project$Routes$href($author$project$Routes$Login)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Have an account?')
														]))
												])),
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('showError')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('alert alert-danger')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(user.aS)
														]))
												])),
											A2(
											$elm$html$Html$form,
											_List_Nil,
											_List_fromArray(
												[
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'color', 'red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(
															A2($elm$core$Maybe$withDefault, '', user.aB))
														])),
													A2(
													$elm$html$Html$fieldset,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('form-group')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$input,
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$class('form-control form-control-lg'),
																	$elm$html$Html$Attributes$type_('text'),
																	$elm$html$Html$Attributes$placeholder('Your Name'),
																	$elm$html$Html$Events$onInput($author$project$Auth$SaveName),
																	$elm$html$Html$Attributes$value(user.j)
																]),
															_List_Nil)
														])),
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'color', 'red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(
															A2($elm$core$Maybe$withDefault, '', user.au))
														])),
													A2(
													$elm$html$Html$fieldset,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('form-group')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$input,
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$class('form-control form-control-lg'),
																	$elm$html$Html$Attributes$type_('email'),
																	$elm$html$Html$Attributes$placeholder('Email'),
																	$elm$html$Html$Events$onInput($author$project$Auth$SaveEmail),
																	$elm$html$Html$Attributes$value(user.bw)
																]),
															_List_Nil)
														])),
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'color', 'red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(
															A2($elm$core$Maybe$withDefault, '', user.ay))
														])),
													A2(
													$elm$html$Html$fieldset,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('form-group')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$input,
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$class('form-control form-control-lg'),
																	$elm$html$Html$Attributes$type_('password'),
																	$elm$html$Html$Attributes$placeholder('Password'),
																	$elm$html$Html$Events$onInput($author$project$Auth$SavePassword),
																	$elm$html$Html$Attributes$value(user.R)
																]),
															_List_Nil)
														])),
													A2(
													$elm$html$Html$button,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right'),
															$elm$html$Html$Attributes$type_('button'),
															$elm$html$Html$Events$onClick($author$project$Auth$Signup)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Sign up')
														]))
												]))
										]))
								]))
						]))
				]));
	}();
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				mainStuff,
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $author$project$Editor$CreateArticle = {$: 4};
var $author$project$Editor$SaveBody = function (a) {
	return {$: 2, a: a};
};
var $author$project$Editor$SaveDescription = function (a) {
	return {$: 1, a: a};
};
var $author$project$Editor$SaveTags = function (a) {
	return {$: 3, a: a};
};
var $author$project$Editor$SaveTitle = function (a) {
	return {$: 0, a: a};
};
var $author$project$Editor$UpdateArticle = {$: 6};
var $author$project$Editor$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('editor-page')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container page')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-md-10 col-md-offset-1 col-xs-12')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$form,
												_List_Nil,
												_List_fromArray(
													[
														A2(
														$elm$html$Html$div,
														_List_fromArray(
															[
																A2($elm$html$Html$Attributes$style, 'color', 'red')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(
																A2($elm$core$Maybe$withDefault, '', model.ao))
															])),
														A2(
														$elm$html$Html$fieldset,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('form-group')
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$input,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-control form-control-lg'),
																		$elm$html$Html$Attributes$type_('text'),
																		$elm$html$Html$Attributes$placeholder('Article Title'),
																		$elm$html$Html$Events$onInput($author$project$Editor$SaveTitle),
																		$elm$html$Html$Attributes$value(model.d.bi)
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$div,
														_List_fromArray(
															[
																A2($elm$html$Html$Attributes$style, 'color', 'red')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(
																A2($elm$core$Maybe$withDefault, '', model.af))
															])),
														A2(
														$elm$html$Html$fieldset,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('form-group')
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$input,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-control'),
																		$elm$html$Html$Attributes$type_('text'),
																		$elm$html$Html$Attributes$placeholder('What\'s this article about?'),
																		$elm$html$Html$Events$onInput($author$project$Editor$SaveDescription),
																		$elm$html$Html$Attributes$value(model.d.bu)
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$div,
														_List_fromArray(
															[
																A2($elm$html$Html$Attributes$style, 'color', 'red')
															]),
														_List_fromArray(
															[
																$elm$html$Html$text(
																A2($elm$core$Maybe$withDefault, '', model.ad))
															])),
														A2(
														$elm$html$Html$fieldset,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('form-group')
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$textarea,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-control'),
																		$elm$html$Html$Attributes$rows(8),
																		$elm$html$Html$Attributes$placeholder('Write your article (in markdown)'),
																		$elm$html$Html$Events$onInput($author$project$Editor$SaveBody),
																		$elm$html$Html$Attributes$value(model.d.z)
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$fieldset,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('form-group')
															]),
														_List_fromArray(
															[
																A2(
																$elm$html$Html$input,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-control'),
																		$elm$html$Html$Attributes$type_('text'),
																		$elm$html$Html$Attributes$placeholder('Enter tags'),
																		$elm$html$Html$Events$onInput($author$project$Editor$SaveTags),
																		$elm$html$Html$Attributes$value(model.aO)
																	]),
																_List_Nil)
															])),
														A2(
														$elm$html$Html$button,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right'),
																$elm$html$Html$Attributes$type_('button'),
																$elm$html$Html$Events$onClick(
																(model.d.J === '') ? $author$project$Editor$CreateArticle : $author$project$Editor$UpdateArticle)
															]),
														_List_fromArray(
															[
																$elm$html$Html$text('Publish Article')
															]))
													]))
											]))
									]))
							]))
					])),
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $elm$core$List$isEmpty = function (xs) {
	if (!xs.b) {
		return true;
	} else {
		return false;
	}
};
var $author$project$Index$monthName = function (month) {
	switch (month) {
		case '01':
			return 'January';
		case '02':
			return 'February';
		case '03':
			return 'March';
		case '04':
			return 'April';
		case '05':
			return 'May';
		case '06':
			return 'June';
		case '07':
			return 'July';
		case '08':
			return 'August';
		case '09':
			return 'September';
		case '10':
			return 'October';
		case '11':
			return 'November';
		case '12':
			return 'December';
		default:
			return 'Invalid month';
	}
};
var $author$project$Index$splitDate = function (dateStr) {
	var parts = A2($elm$core$String$split, '-', dateStr);
	if (((parts.b && parts.b.b) && parts.b.b.b) && (!parts.b.b.b.b)) {
		var year = parts.a;
		var _v1 = parts.b;
		var month = _v1.a;
		var _v2 = _v1.b;
		var dayWithTime = _v2.a;
		var day = A2($elm$core$String$left, 2, dayWithTime);
		return $elm$core$Maybe$Just(
			_Utils_Tuple3(year, month, day));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Index$formatDate = function (dateStr) {
	var _v0 = $author$project$Index$splitDate(dateStr);
	if (!_v0.$) {
		var _v1 = _v0.a;
		var year = _v1.a;
		var month = _v1.b;
		var day = _v1.c;
		return $author$project$Index$monthName(month) + (' ' + (day + (', ' + year)));
	} else {
		return 'Invalid date';
	}
};
var $author$project$Index$maybeImageBio = function (maybeIB) {
	if (!maybeIB.$) {
		var imagebio = maybeIB.a;
		return imagebio;
	} else {
		return '';
	}
};
var $author$project$Index$ToggleLike = function (a) {
	return {$: 0, a: a};
};
var $author$project$Index$viewLoveButton = function (articlePreview) {
	var buttonClass = articlePreview.aJ ? _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-outline-primary btn-sm pull-xs-right'),
			A2($elm$html$Html$Attributes$style, 'background-color', '#d00'),
			A2($elm$html$Html$Attributes$style, 'color', '#fff'),
			A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick(
			$author$project$Index$ToggleLike(articlePreview))
		]) : _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-outline-primary btn-sm pull-xs-right'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick(
			$author$project$Index$ToggleLike(articlePreview))
		]);
	return A2(
		$elm$html$Html$button,
		buttonClass,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-heart')
					]),
				_List_Nil),
				$elm$html$Html$text(
				' ' + $elm$core$String$fromInt(articlePreview.a5))
			]));
};
var $elm$html$Html$ul = _VirtualDom_node('ul');
var $elm$html$Html$li = _VirtualDom_node('li');
var $author$project$Index$viewTagInPreview = function (tag) {
	return A2(
		$elm$html$Html$li,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('tag-default tag-pill tag-outline')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(tag)
			]));
};
var $author$project$Index$viewTagsInPreview = function (maybeTags) {
	return $elm$core$List$isEmpty(maybeTags) ? A2($elm$html$Html$span, _List_Nil, _List_Nil) : A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('tag-list'),
				A2($elm$html$Html$Attributes$style, 'float', 'right')
			]),
		A2($elm$core$List$map, $author$project$Index$viewTagInPreview, maybeTags));
};
var $author$project$Index$viewarticlePreview = function (article) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('post-preview')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('post-meta')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, article.h.j, 1))
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$img,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$src(
										$author$project$Index$maybeImageBio(article.h.O))
									]),
								_List_Nil)
							])),
						$elm$html$Html$text(' '),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('info')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href(
										A2($author$project$Routes$Profile, article.h.j, 1)),
										$elm$html$Html$Attributes$class('author')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(article.h.j)
									])),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('date')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(
										$author$project$Index$formatDate(article.ae))
									]))
							])),
						$author$project$Index$viewLoveButton(article)
					])),
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$author$project$Routes$href(
						$author$project$Routes$Article(article.J)),
						$elm$html$Html$Attributes$class('preview-link')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$h1,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(article.bi)
							])),
						A2(
						$elm$html$Html$p,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(article.bu)
							])),
						A2(
						$elm$html$Html$span,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text('Read more...')
							])),
						$author$project$Index$viewTagsInPreview(article.cf)
					]))
			]));
};
var $author$project$Index$viewArticles = function (maybeFeed) {
	if (!maybeFeed.$) {
		var feed = maybeFeed.a;
		return $elm$core$List$isEmpty(feed) ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('post-preview')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('No articles are here... yet :)')
				])) : A2(
			$elm$html$Html$div,
			_List_Nil,
			A2($elm$core$List$map, $author$project$Index$viewarticlePreview, feed));
	} else {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('post-preview')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Loading feed :)')
				]));
	}
};
var $author$project$Index$LoadTF = function (a) {
	return {$: 7, a: a};
};
var $author$project$Index$viewTag = function (tag) {
	return A2(
		$elm$html$Html$button,
		_List_fromArray(
			[
				$elm$html$Html$Events$onClick(
				$author$project$Index$LoadTF(tag)),
				$elm$html$Html$Attributes$class('tag-pill tag-default'),
				A2($elm$html$Html$Attributes$style, 'border', 'none'),
				(tag === 'welcome') ? $elm$html$Html$Attributes$id('welcome') : $elm$html$Html$Attributes$id('nothing')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(tag)
			]));
};
var $author$project$Index$viewTags = function (maybeTags) {
	if (!maybeTags.$) {
		var tags = maybeTags.a;
		return $elm$core$List$isEmpty(tags) ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('loading-tags')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('There are no tags here... yet :)')
				])) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('tag-list')
				]),
			A2($elm$core$List$map, $author$project$Index$viewTag, tags));
	} else {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('loading-tags')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Loading tags...')
				]));
	}
};
var $author$project$Index$LoadGF = {$: 5};
var $author$project$Index$LoadYF = {$: 6};
var $elm$core$Basics$neq = _Utils_notEqual;
var $author$project$Index$viewThreeFeeds = function (model) {
	return (model.D.T !== '') ? (model._ ? A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadYF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Your Feed')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadGF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Global Feed')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item'),
						$elm$html$Html$Attributes$id('tag')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick(
								$author$project$Index$LoadTF(model.am))
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$i,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('ion-pound')
									]),
								_List_Nil),
								$elm$html$Html$text(' ' + (model.am + ' '))
							]))
					]))
			])) : (model.S ? A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadYF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Your Feed')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadGF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Global Feed')
							]))
					]))
			])) : A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadYF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Your Feed')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadGF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Global Feed')
							]))
					]))
			])))) : (model._ ? A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadGF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Global Feed')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item'),
						$elm$html$Html$Attributes$id('tag')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick(
								$author$project$Index$LoadTF(model.am))
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$i,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('ion-pound')
									]),
								_List_Nil),
								$elm$html$Html$text(' ' + (model.am + ' '))
							]))
					]))
			])) : A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$button,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								A2($elm$html$Html$Attributes$style, 'cursor', 'pointer'),
								$elm$html$Html$Events$onClick($author$project$Index$LoadGF)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Global Feed')
							]))
					]))
			])));
};
var $author$project$Index$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('home-page')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('banner')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('container')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$h1,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('logo-font')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('conduit')
											])),
										A2(
										$elm$html$Html$p,
										_List_Nil,
										_List_fromArray(
											[
												$elm$html$Html$text('A place to share your knowledge.')
											]))
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container page')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-md-9')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('feed-toggle')
													]),
												_List_fromArray(
													[
														$author$project$Index$viewThreeFeeds(model)
													])),
												model._ ? $author$project$Index$viewArticles(model.a_) : (model.S ? $author$project$Index$viewArticles(model.aU) : $author$project$Index$viewArticles(model.a3))
											])),
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-md-3')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('sidebar')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$p,
														_List_Nil,
														_List_fromArray(
															[
																$elm$html$Html$text('Popular Tags')
															])),
														$author$project$Index$viewTags(model.a$)
													]))
											]))
									]))
							]))
					])),
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $author$project$Login$Login = {$: 2};
var $author$project$Login$SaveEmail = function (a) {
	return {$: 0, a: a};
};
var $author$project$Login$SavePassword = function (a) {
	return {$: 1, a: a};
};
var $author$project$Login$view = function (user) {
	var mainStuff = function () {
		var greeting = 'Hello, ' + (user.j + '!');
		return user.be ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$id('greeting')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$h3,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('text-center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text(greeting)
						])),
					A2(
					$elm$html$Html$p,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('text-center')
						]),
					_List_fromArray(
						[
							$elm$html$Html$text('You have successfully logged in!')
						]))
				])) : A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('auth-page')
				]),
			_List_fromArray(
				[
					A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('container page')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$div,
							_List_fromArray(
								[
									$elm$html$Html$Attributes$class('row')
								]),
							_List_fromArray(
								[
									A2(
									$elm$html$Html$div,
									_List_fromArray(
										[
											$elm$html$Html$Attributes$class('col-md-6 col-md-offset-3 col-xs-12')
										]),
									_List_fromArray(
										[
											A2(
											$elm$html$Html$h1,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													$elm$html$Html$text('Log in')
												])),
											A2(
											$elm$html$Html$p,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('text-xs-center')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$a,
													_List_fromArray(
														[
															$author$project$Routes$href($author$project$Routes$Auth)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Don\'t have an account?')
														]))
												])),
											A2(
											$elm$html$Html$div,
											_List_fromArray(
												[
													$elm$html$Html$Attributes$class('showError')
												]),
											_List_fromArray(
												[
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('alert alert-danger')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(user.aS)
														]))
												])),
											A2(
											$elm$html$Html$form,
											_List_Nil,
											_List_fromArray(
												[
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'color', 'red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(
															A2($elm$core$Maybe$withDefault, '', user.au))
														])),
													A2(
													$elm$html$Html$fieldset,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('form-group')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$input,
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$class('form-control form-control-lg'),
																	$elm$html$Html$Attributes$type_('email'),
																	$elm$html$Html$Attributes$placeholder('Email'),
																	$elm$html$Html$Events$onInput($author$project$Login$SaveEmail)
																]),
															_List_Nil)
														])),
													A2(
													$elm$html$Html$div,
													_List_fromArray(
														[
															A2($elm$html$Html$Attributes$style, 'color', 'red')
														]),
													_List_fromArray(
														[
															$elm$html$Html$text(
															A2($elm$core$Maybe$withDefault, '', user.ay))
														])),
													A2(
													$elm$html$Html$fieldset,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('form-group')
														]),
													_List_fromArray(
														[
															A2(
															$elm$html$Html$input,
															_List_fromArray(
																[
																	$elm$html$Html$Attributes$class('form-control form-control-lg'),
																	$elm$html$Html$Attributes$type_('password'),
																	$elm$html$Html$Attributes$placeholder('Password'),
																	$elm$html$Html$Events$onInput($author$project$Login$SavePassword)
																]),
															_List_Nil)
														])),
													A2(
													$elm$html$Html$button,
													_List_fromArray(
														[
															$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right'),
															$elm$html$Html$Attributes$type_('button'),
															$elm$html$Html$Events$onClick($author$project$Login$Login)
														]),
													_List_fromArray(
														[
															$elm$html$Html$text('Log In')
														]))
												]))
										]))
								]))
						]))
				]));
	}();
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				mainStuff,
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $elm$html$Html$h4 = _VirtualDom_node('h4');
var $author$project$Profile$maybeImageBio = function (maybeIB) {
	if (!maybeIB.$) {
		var imagebio = maybeIB.a;
		return imagebio;
	} else {
		return '';
	}
};
var $author$project$Profile$monthName = function (month) {
	switch (month) {
		case '01':
			return 'January';
		case '02':
			return 'February';
		case '03':
			return 'March';
		case '04':
			return 'April';
		case '05':
			return 'May';
		case '06':
			return 'June';
		case '07':
			return 'July';
		case '08':
			return 'August';
		case '09':
			return 'September';
		case '10':
			return 'October';
		case '11':
			return 'November';
		case '12':
			return 'December';
		default:
			return 'Invalid month';
	}
};
var $author$project$Profile$splitDate = function (dateStr) {
	var parts = A2($elm$core$String$split, '-', dateStr);
	if (((parts.b && parts.b.b) && parts.b.b.b) && (!parts.b.b.b.b)) {
		var year = parts.a;
		var _v1 = parts.b;
		var month = _v1.a;
		var _v2 = _v1.b;
		var dayWithTime = _v2.a;
		var day = A2($elm$core$String$left, 2, dayWithTime);
		return $elm$core$Maybe$Just(
			_Utils_Tuple3(year, month, day));
	} else {
		return $elm$core$Maybe$Nothing;
	}
};
var $author$project$Profile$formatDate = function (dateStr) {
	var _v0 = $author$project$Profile$splitDate(dateStr);
	if (!_v0.$) {
		var _v1 = _v0.a;
		var year = _v1.a;
		var month = _v1.b;
		var day = _v1.c;
		return $author$project$Profile$monthName(month) + (' ' + (day + (', ' + year)));
	} else {
		return 'Invalid date';
	}
};
var $author$project$Profile$ToggleLike = function (a) {
	return {$: 0, a: a};
};
var $author$project$Profile$viewLoveButton = function (articlePreview) {
	var buttonClass = articlePreview.aJ ? _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-outline-primary btn-sm pull-xs-right'),
			A2($elm$html$Html$Attributes$style, 'background-color', '#d00'),
			A2($elm$html$Html$Attributes$style, 'color', '#fff'),
			A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick(
			$author$project$Profile$ToggleLike(articlePreview))
		]) : _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-outline-primary btn-sm pull-xs-right'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick(
			$author$project$Profile$ToggleLike(articlePreview))
		]);
	return A2(
		$elm$html$Html$button,
		buttonClass,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-heart')
					]),
				_List_Nil),
				$elm$html$Html$text(
				' ' + $elm$core$String$fromInt(articlePreview.a5))
			]));
};
var $author$project$Profile$viewTagInPreview = function (tag) {
	return A2(
		$elm$html$Html$li,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('tag-default tag-pill tag-outline')
			]),
		_List_fromArray(
			[
				$elm$html$Html$text(tag)
			]));
};
var $author$project$Profile$viewTagsInPreview = function (maybeTags) {
	return $elm$core$List$isEmpty(maybeTags) ? A2($elm$html$Html$span, _List_Nil, _List_Nil) : A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('tag-list'),
				A2($elm$html$Html$Attributes$style, 'float', 'right')
			]),
		A2($elm$core$List$map, $author$project$Profile$viewTagInPreview, maybeTags));
};
var $author$project$Profile$viewArticlePreview = function (article) {
	return A2(
		$elm$html$Html$div,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('post-preview')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('post-meta')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, article.h.j, 1))
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$img,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$src(
										$author$project$Profile$maybeImageBio(article.h.O))
									]),
								_List_Nil)
							])),
						$elm$html$Html$text(' '),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('info')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href(
										A2($author$project$Routes$Profile, article.h.j, 1)),
										$elm$html$Html$Attributes$class('author')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(article.h.j)
									])),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('date')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text(
										$author$project$Profile$formatDate(article.ae))
									]))
							])),
						$author$project$Profile$viewLoveButton(article)
					])),
				A2(
				$elm$html$Html$a,
				_List_fromArray(
					[
						$author$project$Routes$href(
						$author$project$Routes$Article(article.J)),
						$elm$html$Html$Attributes$class('preview-link')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$h1,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(article.bi)
							])),
						A2(
						$elm$html$Html$p,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text(article.bu)
							])),
						A2(
						$elm$html$Html$span,
						_List_Nil,
						_List_fromArray(
							[
								$elm$html$Html$text('Read more...')
							])),
						$author$project$Profile$viewTagsInPreview(article.cf)
					]))
			]));
};
var $author$project$Profile$viewArticles = function (maybeArticlesMade) {
	if (!maybeArticlesMade.$) {
		var articles = maybeArticlesMade.a;
		return $elm$core$List$isEmpty(articles) ? A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('post-preview')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('No articles are here... yet :)')
				])) : A2(
			$elm$html$Html$div,
			_List_Nil,
			A2($elm$core$List$map, $author$project$Profile$viewArticlePreview, articles));
	} else {
		return A2(
			$elm$html$Html$div,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('loading-feed')
				]),
			_List_fromArray(
				[
					$elm$html$Html$text('Loading Feed...')
				]));
	}
};
var $author$project$Profile$ToggleFollow = {$: 1};
var $author$project$Profile$viewFollowButton = function (model) {
	var buttonClass = model.x.aK ? _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-secondary action-btn'),
			A2($elm$html$Html$Attributes$style, 'background-color', 'skyblue'),
			A2($elm$html$Html$Attributes$style, 'color', '#fff'),
			A2($elm$html$Html$Attributes$style, 'border-color', 'black'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Profile$ToggleFollow)
		]) : _List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-secondary action-btn'),
			$elm$html$Html$Attributes$type_('button'),
			$elm$html$Html$Events$onClick($author$project$Profile$ToggleFollow)
		]);
	return A2(
		$elm$html$Html$button,
		buttonClass,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$i,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('ion-plus-round')
					]),
				_List_Nil),
				$elm$html$Html$text(
				' \u00A0 ' + ((model.x.aK ? 'Unfollow' : 'Follow') + (' ' + (model.x.j + ' '))))
			]));
};
var $author$project$Profile$viewSettingsButton = A2(
	$elm$html$Html$a,
	_List_fromArray(
		[
			$elm$html$Html$Attributes$class('btn btn-sm btn-outline-secondary action-btn'),
			$author$project$Routes$href($author$project$Routes$Settings)
		]),
	_List_fromArray(
		[
			A2(
			$elm$html$Html$i,
			_List_fromArray(
				[
					$elm$html$Html$Attributes$class('ion-gear-a')
				]),
			_List_Nil),
			$elm$html$Html$text(' Edit Profile Settings ')
		]));
var $author$project$Profile$viewTwoFeeds = function (model) {
	return model.az ? A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, model.x.j, 1))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('My Articles')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, model.x.j, 0))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Favorited Articles')
							]))
					]))
			])) : A2(
		$elm$html$Html$ul,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('nav nav-pills outline-active')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link'),
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, model.x.j, 1))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('My Articles')
							]))
					])),
				A2(
				$elm$html$Html$li,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('nav-item')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav-link active'),
								$author$project$Routes$href(
								A2($author$project$Routes$Profile, model.x.j, 0))
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('Favorited Articles')
							]))
					]))
			]));
};
var $author$project$Profile$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('profile-page')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('user-info')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('container')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('row')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('col-md-10 col-md-offset-1')
													]),
												_List_fromArray(
													[
														A2(
														$elm$html$Html$img,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$src(
																$author$project$Profile$maybeImageBio(model.x.O)),
																$elm$html$Html$Attributes$class('user-img')
															]),
														_List_Nil),
														A2(
														$elm$html$Html$h4,
														_List_Nil,
														_List_fromArray(
															[
																$elm$html$Html$text(model.x.j)
															])),
														A2(
														$elm$html$Html$p,
														_List_Nil,
														_List_fromArray(
															[
																$elm$html$Html$text(
																$author$project$Profile$maybeImageBio(model.x.aH))
															])),
														$elm$html$Html$text(' '),
														(_Utils_eq(model.D.j, model.x.j) && (model.D.j !== '')) ? $author$project$Profile$viewSettingsButton : $author$project$Profile$viewFollowButton(model)
													]))
											]))
									]))
							])),
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-md-10 col-md-offset-1')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$div,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('articles-toggle')
													]),
												_List_fromArray(
													[
														$author$project$Profile$viewTwoFeeds(model)
													])),
												model.az ? $author$project$Profile$viewArticles(model.E) : $author$project$Profile$viewArticles(model.aw)
											]))
									]))
							]))
					])),
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $author$project$Settings$LogOut = {$: 7};
var $author$project$Settings$SaveBio = function (a) {
	return {$: 2, a: a};
};
var $author$project$Settings$SaveEmail = function (a) {
	return {$: 3, a: a};
};
var $author$project$Settings$SaveName = function (a) {
	return {$: 1, a: a};
};
var $author$project$Settings$SavePassword = function (a) {
	return {$: 4, a: a};
};
var $author$project$Settings$SavePic = function (a) {
	return {$: 0, a: a};
};
var $author$project$Settings$UpdateSettings = {$: 5};
var $elm$html$Html$h2 = _VirtualDom_node('h2');
var $author$project$Settings$maybeImageBio = function (maybeIB) {
	if (!maybeIB.$) {
		var imagebio = maybeIB.a;
		return imagebio;
	} else {
		return '';
	}
};
var $author$project$Settings$view = function (model) {
	return A2(
		$elm$html$Html$div,
		_List_Nil,
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('settings-page')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container page')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$div,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('row')
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$div,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('col-md-6 col-md-offset-3 col-xs-12')
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$h2,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('text-xs-center')
													]),
												_List_fromArray(
													[
														$elm$html$Html$text('Your Settings')
													])),
												A2(
												$elm$html$Html$form,
												_List_Nil,
												_List_fromArray(
													[
														A2(
														$elm$html$Html$fieldset,
														_List_Nil,
														_List_fromArray(
															[
																A2(
																$elm$html$Html$fieldset,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-group')
																	]),
																_List_fromArray(
																	[
																		A2(
																		$elm$html$Html$input,
																		_List_fromArray(
																			[
																				$elm$html$Html$Attributes$class('form-control'),
																				$elm$html$Html$Attributes$type_('text'),
																				$elm$html$Html$Attributes$placeholder('URL of profile picture'),
																				$elm$html$Html$Events$onInput($author$project$Settings$SavePic),
																				$elm$html$Html$Attributes$value(
																				$author$project$Settings$maybeImageBio(model.D.O))
																			]),
																		_List_Nil)
																	])),
																A2(
																$elm$html$Html$div,
																_List_fromArray(
																	[
																		A2($elm$html$Html$Attributes$style, 'color', 'red')
																	]),
																_List_fromArray(
																	[
																		$elm$html$Html$text(
																		A2($elm$core$Maybe$withDefault, '', model.aB))
																	])),
																A2(
																$elm$html$Html$fieldset,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-group')
																	]),
																_List_fromArray(
																	[
																		A2(
																		$elm$html$Html$input,
																		_List_fromArray(
																			[
																				$elm$html$Html$Attributes$class('form-control form-control-lg'),
																				$elm$html$Html$Attributes$type_('text'),
																				$elm$html$Html$Attributes$placeholder('Your Name'),
																				$elm$html$Html$Events$onInput($author$project$Settings$SaveName),
																				$elm$html$Html$Attributes$value(model.D.j)
																			]),
																		_List_Nil)
																	])),
																A2(
																$elm$html$Html$fieldset,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-group')
																	]),
																_List_fromArray(
																	[
																		A2(
																		$elm$html$Html$textarea,
																		_List_fromArray(
																			[
																				$elm$html$Html$Attributes$class('form-control form-control-lg'),
																				$elm$html$Html$Attributes$rows(8),
																				$elm$html$Html$Attributes$placeholder('Short bio about you'),
																				$elm$html$Html$Events$onInput($author$project$Settings$SaveBio),
																				$elm$html$Html$Attributes$value(
																				$author$project$Settings$maybeImageBio(model.D.aH))
																			]),
																		_List_Nil)
																	])),
																A2(
																$elm$html$Html$div,
																_List_fromArray(
																	[
																		A2($elm$html$Html$Attributes$style, 'color', 'red')
																	]),
																_List_fromArray(
																	[
																		$elm$html$Html$text(
																		A2($elm$core$Maybe$withDefault, '', model.au))
																	])),
																A2(
																$elm$html$Html$fieldset,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-group')
																	]),
																_List_fromArray(
																	[
																		A2(
																		$elm$html$Html$input,
																		_List_fromArray(
																			[
																				$elm$html$Html$Attributes$class('form-control form-control-lg'),
																				$elm$html$Html$Attributes$type_('text'),
																				$elm$html$Html$Attributes$placeholder('Email'),
																				$elm$html$Html$Events$onInput($author$project$Settings$SaveEmail),
																				$elm$html$Html$Attributes$value(model.D.bw)
																			]),
																		_List_Nil)
																	])),
																A2(
																$elm$html$Html$fieldset,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('form-group')
																	]),
																_List_fromArray(
																	[
																		A2(
																		$elm$html$Html$input,
																		_List_fromArray(
																			[
																				$elm$html$Html$Attributes$class('form-control form-control-lg'),
																				$elm$html$Html$Attributes$type_('password'),
																				$elm$html$Html$Attributes$placeholder('New Password'),
																				$elm$html$Html$Events$onInput($author$project$Settings$SavePassword)
																			]),
																		_List_Nil)
																	])),
																A2(
																$elm$html$Html$button,
																_List_fromArray(
																	[
																		$elm$html$Html$Attributes$class('btn btn-lg btn-primary pull-xs-right'),
																		$elm$html$Html$Attributes$type_('button'),
																		$elm$html$Html$Events$onClick($author$project$Settings$UpdateSettings)
																	]),
																_List_fromArray(
																	[
																		$elm$html$Html$text('Update Settings')
																	]))
															])),
														A2($elm$html$Html$hr, _List_Nil, _List_Nil),
														A2(
														$elm$html$Html$button,
														_List_fromArray(
															[
																$elm$html$Html$Attributes$class('btn btn-outline-danger'),
																$elm$html$Html$Attributes$type_('button'),
																$elm$html$Html$Events$onClick($author$project$Settings$LogOut)
															]),
														_List_fromArray(
															[
																$elm$html$Html$text('Or click here to logout.')
															]))
													]))
											]))
									]))
							]))
					])),
				A2(
				$elm$html$Html$footer,
				_List_Nil,
				_List_fromArray(
					[
						A2(
						$elm$html$Html$div,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('container')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$a,
								_List_fromArray(
									[
										$author$project$Routes$href($author$project$Routes$Home),
										$elm$html$Html$Attributes$class('logo-font')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('conduit')
									])),
								$elm$html$Html$text(' '),
								A2(
								$elm$html$Html$span,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class('attribution')
									]),
								_List_fromArray(
									[
										$elm$html$Html$text('An interactive learning project from '),
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$href('https://thinkster.io/')
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Thinkster')
											])),
										$elm$html$Html$text('. Code & design licensed under MIT.')
									]))
							]))
					]))
			]));
};
var $author$project$Main$viewContent = function (model) {
	var _v0 = model.e;
	switch (_v0.$) {
		case 0:
			var publicFeedModel = _v0.a;
			return _Utils_Tuple2(
				'Conduit - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$PublicFeedMessage,
					$author$project$Index$view(publicFeedModel)));
		case 1:
			var authUser = _v0.a;
			return _Utils_Tuple2(
				'Auth - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$AuthMessage,
					$author$project$Auth$view(authUser)));
		case 2:
			var editorArticle = _v0.a;
			return _Utils_Tuple2(
				'New Article - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$EditorMessage,
					$author$project$Editor$view(editorArticle)));
		case 3:
			var loginUser = _v0.a;
			return _Utils_Tuple2(
				'Login - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$LoginMessage,
					$author$project$Login$view(loginUser)));
		case 4:
			var articleModel = _v0.a;
			return _Utils_Tuple2(
				articleModel.d.bi + ' - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$ArticleMessage,
					$author$project$Article$view(articleModel)));
		case 5:
			var profileModel = _v0.a;
			return _Utils_Tuple2(
				profileModel.x.j + ' - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$ProfileMessage,
					$author$project$Profile$view(profileModel)));
		case 6:
			var settingsUserSettings = _v0.a;
			return _Utils_Tuple2(
				'Settings - Conduit',
				A2(
					$elm$html$Html$map,
					$author$project$Main$SettingsMessage,
					$author$project$Settings$view(settingsUserSettings)));
		default:
			return _Utils_Tuple2(
				'Not Found - Conduit',
				A2(
					$elm$html$Html$div,
					_List_fromArray(
						[
							$elm$html$Html$Attributes$class('not-found')
						]),
					_List_fromArray(
						[
							A2(
							$elm$html$Html$h1,
							_List_Nil,
							_List_fromArray(
								[
									$elm$html$Html$text('Page Not Found')
								]))
						])));
	}
};
var $author$project$Main$maybeImageBio = function (maybeIB) {
	if (!maybeIB.$) {
		var imagebio = maybeIB.a;
		return imagebio;
	} else {
		return '';
	}
};
var $elm$html$Html$nav = _VirtualDom_node('nav');
var $author$project$Main$viewHeader = function (model) {
	var isActivePage = function (pageName) {
		return _Utils_eq(model.m, pageName) ? 'nav-item active' : 'nav-item';
	};
	return A2(
		$elm$html$Html$nav,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('navbar navbar-light')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('container')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('navbar-brand'),
								$author$project$Routes$href($author$project$Routes$Home)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('conduit')
							])),
						A2(
						$elm$html$Html$ul,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav navbar-nav pull-xs-right')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Home'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$Home)
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Home :)')
											]))
									])),
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Editor'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$NewEditor)
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$i,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('ion-compose')
													]),
												_List_Nil),
												$elm$html$Html$text(' ' + 'New Article')
											]))
									])),
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Settings'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$Settings)
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$i,
												_List_fromArray(
													[
														$elm$html$Html$Attributes$class('ion-gear-a')
													]),
												_List_Nil),
												$elm$html$Html$text(' Settings')
											]))
									])),
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Profile'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href(
												A2($author$project$Routes$Profile, model.D.j, 1))
											]),
										_List_fromArray(
											[
												A2(
												$elm$html$Html$img,
												_List_fromArray(
													[
														A2($elm$html$Html$Attributes$style, 'width', '32px'),
														A2($elm$html$Html$Attributes$style, 'height', '32px'),
														A2($elm$html$Html$Attributes$style, 'border-radius', '30px'),
														$elm$html$Html$Attributes$src(
														$author$project$Main$maybeImageBio(model.D.O))
													]),
												_List_Nil),
												$elm$html$Html$text(' ' + model.D.j)
											]))
									]))
							]))
					]))
			]));
};
var $author$project$Main$viewHeaderLO = function (model) {
	var isActivePage = function (pageName) {
		return _Utils_eq(model.m, pageName) ? 'nav-item active' : 'nav-item';
	};
	return A2(
		$elm$html$Html$nav,
		_List_fromArray(
			[
				$elm$html$Html$Attributes$class('navbar navbar-light')
			]),
		_List_fromArray(
			[
				A2(
				$elm$html$Html$div,
				_List_fromArray(
					[
						$elm$html$Html$Attributes$class('container')
					]),
				_List_fromArray(
					[
						A2(
						$elm$html$Html$a,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('navbar-brand'),
								$author$project$Routes$href($author$project$Routes$Home)
							]),
						_List_fromArray(
							[
								$elm$html$Html$text('conduit')
							])),
						A2(
						$elm$html$Html$ul,
						_List_fromArray(
							[
								$elm$html$Html$Attributes$class('nav navbar-nav pull-xs-right')
							]),
						_List_fromArray(
							[
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Home'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$Home)
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Home :)')
											]))
									])),
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Login'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$Login)
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Log in')
											]))
									])),
								A2(
								$elm$html$Html$li,
								_List_fromArray(
									[
										$elm$html$Html$Attributes$class(
										isActivePage('Auth'))
									]),
								_List_fromArray(
									[
										A2(
										$elm$html$Html$a,
										_List_fromArray(
											[
												$elm$html$Html$Attributes$class('nav-link'),
												$author$project$Routes$href($author$project$Routes$Auth)
											]),
										_List_fromArray(
											[
												$elm$html$Html$text('Sign up')
											]))
									]))
							]))
					]))
			]));
};
var $author$project$Main$view = function (model) {
	var _v0 = $author$project$Main$viewContent(model);
	var title = _v0.a;
	var content = _v0.b;
	return model.ax ? {
		z: _List_fromArray(
			[
				$author$project$Main$viewHeader(model),
				content
			]),
		bi: title
	} : {
		z: _List_fromArray(
			[
				$author$project$Main$viewHeaderLO(model),
				content
			]),
		bi: title
	};
};
var $author$project$Main$main = $elm$browser$Browser$application(
	{
		cM: $author$project$Main$init,
		c2: A2($elm$core$Basics$composeR, $author$project$Routes$match, $author$project$Main$NewRoute),
		c3: $author$project$Main$Visit,
		dh: $author$project$Main$subscriptions,
		dl: $author$project$Main$update,
		dn: $author$project$Main$view
	});
_Platform_export({'Main':{'init':$author$project$Main$main(
	$elm$json$Json$Decode$succeed(0))(0)}});}(this));