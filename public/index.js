(() => {
  // output/Control.Bind/foreign.js
  var arrayBind = typeof Array.prototype.flatMap === "function" ? function(arr) {
    return function(f) {
      return arr.flatMap(f);
    };
  } : function(arr) {
    return function(f) {
      var result = [];
      var l = arr.length;
      for (var i = 0; i < l; i++) {
        var xs = f(arr[i]);
        var k = xs.length;
        for (var j = 0; j < k; j++) {
          result.push(xs[j]);
        }
      }
      return result;
    };
  };

  // output/Control.Apply/foreign.js
  var arrayApply = function(fs) {
    return function(xs) {
      var l = fs.length;
      var k = xs.length;
      var result = new Array(l * k);
      var n = 0;
      for (var i = 0; i < l; i++) {
        var f = fs[i];
        for (var j = 0; j < k; j++) {
          result[n++] = f(xs[j]);
        }
      }
      return result;
    };
  };

  // output/Control.Semigroupoid/index.js
  var semigroupoidFn = {
    compose: function(f) {
      return function(g) {
        return function(x) {
          return f(g(x));
        };
      };
    }
  };
  var compose = function(dict) {
    return dict.compose;
  };

  // output/Control.Category/index.js
  var identity = function(dict) {
    return dict.identity;
  };
  var categoryFn = {
    identity: function(x) {
      return x;
    },
    Semigroupoid0: function() {
      return semigroupoidFn;
    }
  };

  // output/Data.Boolean/index.js
  var otherwise = true;

  // output/Data.Function/index.js
  var flip = function(f) {
    return function(b) {
      return function(a) {
        return f(a)(b);
      };
    };
  };
  var $$const = function(a) {
    return function(v) {
      return a;
    };
  };

  // output/Data.Functor/foreign.js
  var arrayMap = function(f) {
    return function(arr) {
      var l = arr.length;
      var result = new Array(l);
      for (var i = 0; i < l; i++) {
        result[i] = f(arr[i]);
      }
      return result;
    };
  };

  // output/Data.Unit/foreign.js
  var unit = void 0;

  // output/Type.Proxy/index.js
  var $$Proxy = /* @__PURE__ */ function() {
    function $$Proxy2() {
    }
    ;
    $$Proxy2.value = new $$Proxy2();
    return $$Proxy2;
  }();

  // output/Data.Functor/index.js
  var map = function(dict) {
    return dict.map;
  };
  var mapFlipped = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return function(fa) {
      return function(f) {
        return map111(f)(fa);
      };
    };
  };
  var $$void = function(dictFunctor) {
    return map(dictFunctor)($$const(unit));
  };
  var voidLeft = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return function(f) {
      return function(x) {
        return map111($$const(x))(f);
      };
    };
  };
  var voidRight = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return function(x) {
      return map111($$const(x));
    };
  };
  var functorFn = {
    map: /* @__PURE__ */ compose(semigroupoidFn)
  };
  var functorArray = {
    map: arrayMap
  };

  // output/Control.Apply/index.js
  var identity2 = /* @__PURE__ */ identity(categoryFn);
  var applyFn = {
    apply: function(f) {
      return function(g) {
        return function(x) {
          return f(x)(g(x));
        };
      };
    },
    Functor0: function() {
      return functorFn;
    }
  };
  var applyArray = {
    apply: arrayApply,
    Functor0: function() {
      return functorArray;
    }
  };
  var apply = function(dict) {
    return dict.apply;
  };
  var applySecond = function(dictApply) {
    var apply1 = apply(dictApply);
    var map24 = map(dictApply.Functor0());
    return function(a) {
      return function(b) {
        return apply1(map24($$const(identity2))(a))(b);
      };
    };
  };

  // output/Control.Applicative/index.js
  var pure = function(dict) {
    return dict.pure;
  };
  var unless = function(dictApplicative) {
    var pure110 = pure(dictApplicative);
    return function(v) {
      return function(v1) {
        if (!v) {
          return v1;
        }
        ;
        if (v) {
          return pure110(unit);
        }
        ;
        throw new Error("Failed pattern match at Control.Applicative (line 68, column 1 - line 68, column 65): " + [v.constructor.name, v1.constructor.name]);
      };
    };
  };
  var when = function(dictApplicative) {
    var pure110 = pure(dictApplicative);
    return function(v) {
      return function(v1) {
        if (v) {
          return v1;
        }
        ;
        if (!v) {
          return pure110(unit);
        }
        ;
        throw new Error("Failed pattern match at Control.Applicative (line 63, column 1 - line 63, column 63): " + [v.constructor.name, v1.constructor.name]);
      };
    };
  };
  var liftA1 = function(dictApplicative) {
    var apply6 = apply(dictApplicative.Apply0());
    var pure110 = pure(dictApplicative);
    return function(f) {
      return function(a) {
        return apply6(pure110(f))(a);
      };
    };
  };
  var applicativeArray = {
    pure: function(x) {
      return [x];
    },
    Apply0: function() {
      return applyArray;
    }
  };

  // output/Control.Bind/index.js
  var identity3 = /* @__PURE__ */ identity(categoryFn);
  var discard = function(dict) {
    return dict.discard;
  };
  var bindArray = {
    bind: arrayBind,
    Apply0: function() {
      return applyArray;
    }
  };
  var bind = function(dict) {
    return dict.bind;
  };
  var bindFlipped = function(dictBind) {
    return flip(bind(dictBind));
  };
  var composeKleisliFlipped = function(dictBind) {
    var bindFlipped1 = bindFlipped(dictBind);
    return function(f) {
      return function(g) {
        return function(a) {
          return bindFlipped1(f)(g(a));
        };
      };
    };
  };
  var discardUnit = {
    discard: function(dictBind) {
      return bind(dictBind);
    }
  };
  var join = function(dictBind) {
    var bind110 = bind(dictBind);
    return function(m) {
      return bind110(m)(identity3);
    };
  };

  // output/Data.Semigroup/foreign.js
  var concatString = function(s1) {
    return function(s2) {
      return s1 + s2;
    };
  };
  var concatArray = function(xs) {
    return function(ys) {
      if (xs.length === 0) return ys;
      if (ys.length === 0) return xs;
      return xs.concat(ys);
    };
  };

  // output/Data.Symbol/index.js
  var reflectSymbol = function(dict) {
    return dict.reflectSymbol;
  };

  // output/Record.Unsafe/foreign.js
  var unsafeGet = function(label4) {
    return function(rec) {
      return rec[label4];
    };
  };
  var unsafeSet = function(label4) {
    return function(value12) {
      return function(rec) {
        var copy = {};
        for (var key2 in rec) {
          if ({}.hasOwnProperty.call(rec, key2)) {
            copy[key2] = rec[key2];
          }
        }
        copy[label4] = value12;
        return copy;
      };
    };
  };
  var unsafeDelete = function(label4) {
    return function(rec) {
      var copy = {};
      for (var key2 in rec) {
        if (key2 !== label4 && {}.hasOwnProperty.call(rec, key2)) {
          copy[key2] = rec[key2];
        }
      }
      return copy;
    };
  };

  // output/Data.Semigroup/index.js
  var semigroupString = {
    append: concatString
  };
  var semigroupArray = {
    append: concatArray
  };
  var append = function(dict) {
    return dict.append;
  };

  // output/Control.Alt/index.js
  var alt = function(dict) {
    return dict.alt;
  };

  // output/Data.Bounded/foreign.js
  var topInt = 2147483647;
  var bottomInt = -2147483648;
  var topChar = String.fromCharCode(65535);
  var bottomChar = String.fromCharCode(0);
  var topNumber = Number.POSITIVE_INFINITY;
  var bottomNumber = Number.NEGATIVE_INFINITY;

  // output/Data.Ord/foreign.js
  var unsafeCompareImpl = function(lt) {
    return function(eq3) {
      return function(gt) {
        return function(x) {
          return function(y) {
            return x < y ? lt : x === y ? eq3 : gt;
          };
        };
      };
    };
  };
  var ordIntImpl = unsafeCompareImpl;
  var ordNumberImpl = unsafeCompareImpl;
  var ordStringImpl = unsafeCompareImpl;

  // output/Data.Eq/foreign.js
  var refEq = function(r1) {
    return function(r2) {
      return r1 === r2;
    };
  };
  var eqIntImpl = refEq;
  var eqNumberImpl = refEq;
  var eqStringImpl = refEq;

  // output/Data.Eq/index.js
  var eqString = {
    eq: eqStringImpl
  };
  var eqNumber = {
    eq: eqNumberImpl
  };
  var eqInt = {
    eq: eqIntImpl
  };
  var eq = function(dict) {
    return dict.eq;
  };

  // output/Data.Ordering/index.js
  var LT = /* @__PURE__ */ function() {
    function LT2() {
    }
    ;
    LT2.value = new LT2();
    return LT2;
  }();
  var GT = /* @__PURE__ */ function() {
    function GT2() {
    }
    ;
    GT2.value = new GT2();
    return GT2;
  }();
  var EQ = /* @__PURE__ */ function() {
    function EQ2() {
    }
    ;
    EQ2.value = new EQ2();
    return EQ2;
  }();

  // output/Data.Ord/index.js
  var ordString = /* @__PURE__ */ function() {
    return {
      compare: ordStringImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqString;
      }
    };
  }();
  var ordNumber = /* @__PURE__ */ function() {
    return {
      compare: ordNumberImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqNumber;
      }
    };
  }();
  var ordInt = /* @__PURE__ */ function() {
    return {
      compare: ordIntImpl(LT.value)(EQ.value)(GT.value),
      Eq0: function() {
        return eqInt;
      }
    };
  }();
  var compare = function(dict) {
    return dict.compare;
  };
  var max = function(dictOrd) {
    var compare3 = compare(dictOrd);
    return function(x) {
      return function(y) {
        var v = compare3(x)(y);
        if (v instanceof LT) {
          return y;
        }
        ;
        if (v instanceof EQ) {
          return x;
        }
        ;
        if (v instanceof GT) {
          return x;
        }
        ;
        throw new Error("Failed pattern match at Data.Ord (line 181, column 3 - line 184, column 12): " + [v.constructor.name]);
      };
    };
  };
  var min = function(dictOrd) {
    var compare3 = compare(dictOrd);
    return function(x) {
      return function(y) {
        var v = compare3(x)(y);
        if (v instanceof LT) {
          return x;
        }
        ;
        if (v instanceof EQ) {
          return x;
        }
        ;
        if (v instanceof GT) {
          return y;
        }
        ;
        throw new Error("Failed pattern match at Data.Ord (line 172, column 3 - line 175, column 12): " + [v.constructor.name]);
      };
    };
  };

  // output/Data.Bounded/index.js
  var top = function(dict) {
    return dict.top;
  };
  var boundedInt = {
    top: topInt,
    bottom: bottomInt,
    Ord0: function() {
      return ordInt;
    }
  };
  var bottom = function(dict) {
    return dict.bottom;
  };

  // output/Data.Show/foreign.js
  var showIntImpl = function(n) {
    return n.toString();
  };
  var showNumberImpl = function(n) {
    var str = n.toString();
    return isNaN(str + ".0") ? str : str + ".0";
  };
  var showStringImpl = function(s) {
    var l = s.length;
    return '"' + s.replace(
      /[\0-\x1F\x7F"\\]/g,
      // eslint-disable-line no-control-regex
      function(c, i) {
        switch (c) {
          case '"':
          case "\\":
            return "\\" + c;
          case "\x07":
            return "\\a";
          case "\b":
            return "\\b";
          case "\f":
            return "\\f";
          case "\n":
            return "\\n";
          case "\r":
            return "\\r";
          case "	":
            return "\\t";
          case "\v":
            return "\\v";
        }
        var k = i + 1;
        var empty7 = k < l && s[k] >= "0" && s[k] <= "9" ? "\\&" : "";
        return "\\" + c.charCodeAt(0).toString(10) + empty7;
      }
    ) + '"';
  };

  // output/Data.Show/index.js
  var showString = {
    show: showStringImpl
  };
  var showNumber = {
    show: showNumberImpl
  };
  var showInt = {
    show: showIntImpl
  };
  var show = function(dict) {
    return dict.show;
  };

  // output/Data.Maybe/index.js
  var identity4 = /* @__PURE__ */ identity(categoryFn);
  var Nothing = /* @__PURE__ */ function() {
    function Nothing2() {
    }
    ;
    Nothing2.value = new Nothing2();
    return Nothing2;
  }();
  var Just = /* @__PURE__ */ function() {
    function Just2(value0) {
      this.value0 = value0;
    }
    ;
    Just2.create = function(value0) {
      return new Just2(value0);
    };
    return Just2;
  }();
  var showMaybe = function(dictShow) {
    var show16 = show(dictShow);
    return {
      show: function(v) {
        if (v instanceof Just) {
          return "(Just " + (show16(v.value0) + ")");
        }
        ;
        if (v instanceof Nothing) {
          return "Nothing";
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 223, column 1 - line 225, column 28): " + [v.constructor.name]);
      }
    };
  };
  var maybe$prime = function(v) {
    return function(v1) {
      return function(v2) {
        if (v2 instanceof Nothing) {
          return v(unit);
        }
        ;
        if (v2 instanceof Just) {
          return v1(v2.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 250, column 1 - line 250, column 62): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
      };
    };
  };
  var maybe = function(v) {
    return function(v1) {
      return function(v2) {
        if (v2 instanceof Nothing) {
          return v;
        }
        ;
        if (v2 instanceof Just) {
          return v1(v2.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 237, column 1 - line 237, column 51): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
      };
    };
  };
  var isNothing = /* @__PURE__ */ maybe(true)(/* @__PURE__ */ $$const(false));
  var isJust = /* @__PURE__ */ maybe(false)(/* @__PURE__ */ $$const(true));
  var functorMaybe = {
    map: function(v) {
      return function(v1) {
        if (v1 instanceof Just) {
          return new Just(v(v1.value0));
        }
        ;
        return Nothing.value;
      };
    }
  };
  var map2 = /* @__PURE__ */ map(functorMaybe);
  var fromMaybe$prime = function(a) {
    return maybe$prime(a)(identity4);
  };
  var fromMaybe = function(a) {
    return maybe(a)(identity4);
  };
  var fromJust = function() {
    return function(v) {
      if (v instanceof Just) {
        return v.value0;
      }
      ;
      throw new Error("Failed pattern match at Data.Maybe (line 288, column 1 - line 288, column 46): " + [v.constructor.name]);
    };
  };
  var applyMaybe = {
    apply: function(v) {
      return function(v1) {
        if (v instanceof Just) {
          return map2(v.value0)(v1);
        }
        ;
        if (v instanceof Nothing) {
          return Nothing.value;
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 67, column 1 - line 69, column 30): " + [v.constructor.name, v1.constructor.name]);
      };
    },
    Functor0: function() {
      return functorMaybe;
    }
  };
  var bindMaybe = {
    bind: function(v) {
      return function(v1) {
        if (v instanceof Just) {
          return v1(v.value0);
        }
        ;
        if (v instanceof Nothing) {
          return Nothing.value;
        }
        ;
        throw new Error("Failed pattern match at Data.Maybe (line 125, column 1 - line 127, column 28): " + [v.constructor.name, v1.constructor.name]);
      };
    },
    Apply0: function() {
      return applyMaybe;
    }
  };
  var altMaybe = {
    alt: function(v) {
      return function(v1) {
        if (v instanceof Nothing) {
          return v1;
        }
        ;
        return v;
      };
    },
    Functor0: function() {
      return functorMaybe;
    }
  };

  // output/Data.Foldable/foreign.js
  var foldrArray = function(f) {
    return function(init3) {
      return function(xs) {
        var acc = init3;
        var len = xs.length;
        for (var i = len - 1; i >= 0; i--) {
          acc = f(xs[i])(acc);
        }
        return acc;
      };
    };
  };
  var foldlArray = function(f) {
    return function(init3) {
      return function(xs) {
        var acc = init3;
        var len = xs.length;
        for (var i = 0; i < len; i++) {
          acc = f(acc)(xs[i]);
        }
        return acc;
      };
    };
  };

  // output/Control.Plus/index.js
  var empty = function(dict) {
    return dict.empty;
  };

  // output/Data.Either/index.js
  var Left = /* @__PURE__ */ function() {
    function Left2(value0) {
      this.value0 = value0;
    }
    ;
    Left2.create = function(value0) {
      return new Left2(value0);
    };
    return Left2;
  }();
  var Right = /* @__PURE__ */ function() {
    function Right2(value0) {
      this.value0 = value0;
    }
    ;
    Right2.create = function(value0) {
      return new Right2(value0);
    };
    return Right2;
  }();
  var functorEither = {
    map: function(f) {
      return function(m) {
        if (m instanceof Left) {
          return new Left(m.value0);
        }
        ;
        if (m instanceof Right) {
          return new Right(f(m.value0));
        }
        ;
        throw new Error("Failed pattern match at Data.Either (line 0, column 0 - line 0, column 0): " + [m.constructor.name]);
      };
    }
  };
  var either = function(v) {
    return function(v1) {
      return function(v2) {
        if (v2 instanceof Left) {
          return v(v2.value0);
        }
        ;
        if (v2 instanceof Right) {
          return v1(v2.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Either (line 208, column 1 - line 208, column 64): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
      };
    };
  };
  var hush = /* @__PURE__ */ function() {
    return either($$const(Nothing.value))(Just.create);
  }();

  // output/Data.HeytingAlgebra/foreign.js
  var boolConj = function(b1) {
    return function(b2) {
      return b1 && b2;
    };
  };
  var boolDisj = function(b1) {
    return function(b2) {
      return b1 || b2;
    };
  };
  var boolNot = function(b) {
    return !b;
  };

  // output/Data.HeytingAlgebra/index.js
  var not = function(dict) {
    return dict.not;
  };
  var disj = function(dict) {
    return dict.disj;
  };
  var heytingAlgebraBoolean = {
    ff: false,
    tt: true,
    implies: function(a) {
      return function(b) {
        return disj(heytingAlgebraBoolean)(not(heytingAlgebraBoolean)(a))(b);
      };
    },
    conj: boolConj,
    disj: boolDisj,
    not: boolNot
  };

  // output/Data.Monoid/index.js
  var monoidString = {
    mempty: "",
    Semigroup0: function() {
      return semigroupString;
    }
  };
  var monoidArray = {
    mempty: [],
    Semigroup0: function() {
      return semigroupArray;
    }
  };
  var mempty = function(dict) {
    return dict.mempty;
  };

  // output/Data.Tuple/index.js
  var Tuple = /* @__PURE__ */ function() {
    function Tuple2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Tuple2.create = function(value0) {
      return function(value1) {
        return new Tuple2(value0, value1);
      };
    };
    return Tuple2;
  }();
  var snd = function(v) {
    return v.value1;
  };
  var fst = function(v) {
    return v.value0;
  };

  // output/Data.Bifunctor/index.js
  var identity5 = /* @__PURE__ */ identity(categoryFn);
  var bimap = function(dict) {
    return dict.bimap;
  };
  var lmap = function(dictBifunctor) {
    var bimap1 = bimap(dictBifunctor);
    return function(f) {
      return bimap1(f)(identity5);
    };
  };
  var bifunctorTuple = {
    bimap: function(f) {
      return function(g) {
        return function(v) {
          return new Tuple(f(v.value0), g(v.value1));
        };
      };
    }
  };
  var bifunctorEither = {
    bimap: function(v) {
      return function(v1) {
        return function(v2) {
          if (v2 instanceof Left) {
            return new Left(v(v2.value0));
          }
          ;
          if (v2 instanceof Right) {
            return new Right(v1(v2.value0));
          }
          ;
          throw new Error("Failed pattern match at Data.Bifunctor (line 38, column 1 - line 40, column 36): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
        };
      };
    }
  };

  // output/Unsafe.Coerce/foreign.js
  var unsafeCoerce2 = function(x) {
    return x;
  };

  // output/Safe.Coerce/index.js
  var coerce = function() {
    return unsafeCoerce2;
  };

  // output/Data.Newtype/index.js
  var coerce2 = /* @__PURE__ */ coerce();
  var wrap = function() {
    return coerce2;
  };
  var unwrap = function() {
    return coerce2;
  };

  // output/Data.Foldable/index.js
  var foldr = function(dict) {
    return dict.foldr;
  };
  var $$null = function(dictFoldable) {
    return foldr(dictFoldable)(function(v) {
      return function(v1) {
        return false;
      };
    })(true);
  };
  var traverse_ = function(dictApplicative) {
    var applySecond6 = applySecond(dictApplicative.Apply0());
    var pure24 = pure(dictApplicative);
    return function(dictFoldable) {
      var foldr3 = foldr(dictFoldable);
      return function(f) {
        return foldr3(function($473) {
          return applySecond6(f($473));
        })(pure24(unit));
      };
    };
  };
  var foldl = function(dict) {
    return dict.foldl;
  };
  var intercalate = function(dictFoldable) {
    var foldl32 = foldl(dictFoldable);
    return function(dictMonoid) {
      var append6 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(sep) {
        return function(xs) {
          var go2 = function(v) {
            return function(v1) {
              if (v.init) {
                return {
                  init: false,
                  acc: v1
                };
              }
              ;
              return {
                init: false,
                acc: append6(v.acc)(append6(sep)(v1))
              };
            };
          };
          return foldl32(go2)({
            init: true,
            acc: mempty3
          })(xs).acc;
        };
      };
    };
  };
  var foldableMaybe = {
    foldr: function(v) {
      return function(v1) {
        return function(v2) {
          if (v2 instanceof Nothing) {
            return v1;
          }
          ;
          if (v2 instanceof Just) {
            return v(v2.value0)(v1);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 186, column 1 - line 192, column 27): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
        };
      };
    },
    foldl: function(v) {
      return function(v1) {
        return function(v2) {
          if (v2 instanceof Nothing) {
            return v1;
          }
          ;
          if (v2 instanceof Just) {
            return v(v1)(v2.value0);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 186, column 1 - line 192, column 27): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
        };
      };
    },
    foldMap: function(dictMonoid) {
      var mempty3 = mempty(dictMonoid);
      return function(v) {
        return function(v1) {
          if (v1 instanceof Nothing) {
            return mempty3;
          }
          ;
          if (v1 instanceof Just) {
            return v(v1.value0);
          }
          ;
          throw new Error("Failed pattern match at Data.Foldable (line 186, column 1 - line 192, column 27): " + [v.constructor.name, v1.constructor.name]);
        };
      };
    }
  };
  var foldMapDefaultR = function(dictFoldable) {
    var foldr3 = foldr(dictFoldable);
    return function(dictMonoid) {
      var append6 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldr3(function(x) {
          return function(acc) {
            return append6(f(x))(acc);
          };
        })(mempty3);
      };
    };
  };
  var foldableArray = {
    foldr: foldrArray,
    foldl: foldlArray,
    foldMap: function(dictMonoid) {
      return foldMapDefaultR(foldableArray)(dictMonoid);
    }
  };

  // output/Data.FunctorWithIndex/foreign.js
  var mapWithIndexArray = function(f) {
    return function(xs) {
      var l = xs.length;
      var result = Array(l);
      for (var i = 0; i < l; i++) {
        result[i] = f(i)(xs[i]);
      }
      return result;
    };
  };

  // output/Data.Identity/index.js
  var Identity = function(x) {
    return x;
  };
  var functorIdentity = {
    map: function(f) {
      return function(m) {
        return f(m);
      };
    }
  };
  var applyIdentity = {
    apply: function(v) {
      return function(v1) {
        return v(v1);
      };
    },
    Functor0: function() {
      return functorIdentity;
    }
  };
  var bindIdentity = {
    bind: function(v) {
      return function(f) {
        return f(v);
      };
    },
    Apply0: function() {
      return applyIdentity;
    }
  };
  var applicativeIdentity = {
    pure: Identity,
    Apply0: function() {
      return applyIdentity;
    }
  };
  var monadIdentity = {
    Applicative0: function() {
      return applicativeIdentity;
    },
    Bind1: function() {
      return bindIdentity;
    }
  };

  // output/Data.FunctorWithIndex/index.js
  var mapWithIndex = function(dict) {
    return dict.mapWithIndex;
  };
  var functorWithIndexArray = {
    mapWithIndex: mapWithIndexArray,
    Functor0: function() {
      return functorArray;
    }
  };

  // output/Data.Traversable/foreign.js
  var traverseArrayImpl = /* @__PURE__ */ function() {
    function array1(a) {
      return [a];
    }
    function array2(a) {
      return function(b) {
        return [a, b];
      };
    }
    function array3(a) {
      return function(b) {
        return function(c) {
          return [a, b, c];
        };
      };
    }
    function concat2(xs) {
      return function(ys) {
        return xs.concat(ys);
      };
    }
    return function(apply6) {
      return function(map24) {
        return function(pure24) {
          return function(f) {
            return function(array) {
              function go2(bot, top3) {
                switch (top3 - bot) {
                  case 0:
                    return pure24([]);
                  case 1:
                    return map24(array1)(f(array[bot]));
                  case 2:
                    return apply6(map24(array2)(f(array[bot])))(f(array[bot + 1]));
                  case 3:
                    return apply6(apply6(map24(array3)(f(array[bot])))(f(array[bot + 1])))(f(array[bot + 2]));
                  default:
                    var pivot = bot + Math.floor((top3 - bot) / 4) * 2;
                    return apply6(map24(concat2)(go2(bot, pivot)))(go2(pivot, top3));
                }
              }
              return go2(0, array.length);
            };
          };
        };
      };
    };
  }();

  // output/Data.Traversable/index.js
  var identity6 = /* @__PURE__ */ identity(categoryFn);
  var traverse = function(dict) {
    return dict.traverse;
  };
  var traversableMaybe = {
    traverse: function(dictApplicative) {
      var pure24 = pure(dictApplicative);
      var map24 = map(dictApplicative.Apply0().Functor0());
      return function(v) {
        return function(v1) {
          if (v1 instanceof Nothing) {
            return pure24(Nothing.value);
          }
          ;
          if (v1 instanceof Just) {
            return map24(Just.create)(v(v1.value0));
          }
          ;
          throw new Error("Failed pattern match at Data.Traversable (line 115, column 1 - line 119, column 33): " + [v.constructor.name, v1.constructor.name]);
        };
      };
    },
    sequence: function(dictApplicative) {
      var pure24 = pure(dictApplicative);
      var map24 = map(dictApplicative.Apply0().Functor0());
      return function(v) {
        if (v instanceof Nothing) {
          return pure24(Nothing.value);
        }
        ;
        if (v instanceof Just) {
          return map24(Just.create)(v.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Traversable (line 115, column 1 - line 119, column 33): " + [v.constructor.name]);
      };
    },
    Functor0: function() {
      return functorMaybe;
    },
    Foldable1: function() {
      return foldableMaybe;
    }
  };
  var sequenceDefault = function(dictTraversable) {
    var traverse22 = traverse(dictTraversable);
    return function(dictApplicative) {
      return traverse22(dictApplicative)(identity6);
    };
  };
  var traversableArray = {
    traverse: function(dictApplicative) {
      var Apply0 = dictApplicative.Apply0();
      return traverseArrayImpl(apply(Apply0))(map(Apply0.Functor0()))(pure(dictApplicative));
    },
    sequence: function(dictApplicative) {
      return sequenceDefault(traversableArray)(dictApplicative);
    },
    Functor0: function() {
      return functorArray;
    },
    Foldable1: function() {
      return foldableArray;
    }
  };

  // output/Data.Unfoldable/foreign.js
  var unfoldrArrayImpl = function(isNothing2) {
    return function(fromJust4) {
      return function(fst2) {
        return function(snd2) {
          return function(f) {
            return function(b) {
              var result = [];
              var value12 = b;
              while (true) {
                var maybe2 = f(value12);
                if (isNothing2(maybe2)) return result;
                var tuple = fromJust4(maybe2);
                result.push(fst2(tuple));
                value12 = snd2(tuple);
              }
            };
          };
        };
      };
    };
  };

  // output/Data.Unfoldable1/foreign.js
  var unfoldr1ArrayImpl = function(isNothing2) {
    return function(fromJust4) {
      return function(fst2) {
        return function(snd2) {
          return function(f) {
            return function(b) {
              var result = [];
              var value12 = b;
              while (true) {
                var tuple = f(value12);
                result.push(fst2(tuple));
                var maybe2 = snd2(tuple);
                if (isNothing2(maybe2)) return result;
                value12 = fromJust4(maybe2);
              }
            };
          };
        };
      };
    };
  };

  // output/Data.Unfoldable1/index.js
  var fromJust2 = /* @__PURE__ */ fromJust();
  var unfoldable1Array = {
    unfoldr1: /* @__PURE__ */ unfoldr1ArrayImpl(isNothing)(fromJust2)(fst)(snd)
  };

  // output/Data.Unfoldable/index.js
  var fromJust3 = /* @__PURE__ */ fromJust();
  var unfoldr = function(dict) {
    return dict.unfoldr;
  };
  var unfoldableArray = {
    unfoldr: /* @__PURE__ */ unfoldrArrayImpl(isNothing)(fromJust3)(fst)(snd),
    Unfoldable10: function() {
      return unfoldable1Array;
    }
  };

  // output/Data.NonEmpty/index.js
  var NonEmpty = /* @__PURE__ */ function() {
    function NonEmpty2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    NonEmpty2.create = function(value0) {
      return function(value1) {
        return new NonEmpty2(value0, value1);
      };
    };
    return NonEmpty2;
  }();
  var singleton2 = function(dictPlus) {
    var empty7 = empty(dictPlus);
    return function(a) {
      return new NonEmpty(a, empty7);
    };
  };
  var showNonEmpty = function(dictShow) {
    var show16 = show(dictShow);
    return function(dictShow1) {
      var show17 = show(dictShow1);
      return {
        show: function(v) {
          return "(NonEmpty " + (show16(v.value0) + (" " + (show17(v.value1) + ")")));
        }
      };
    };
  };
  var functorNonEmpty = function(dictFunctor) {
    var map24 = map(dictFunctor);
    return {
      map: function(f) {
        return function(m) {
          return new NonEmpty(f(m.value0), map24(f)(m.value1));
        };
      }
    };
  };

  // output/Data.List.Types/index.js
  var Nil = /* @__PURE__ */ function() {
    function Nil2() {
    }
    ;
    Nil2.value = new Nil2();
    return Nil2;
  }();
  var Cons = /* @__PURE__ */ function() {
    function Cons2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Cons2.create = function(value0) {
      return function(value1) {
        return new Cons2(value0, value1);
      };
    };
    return Cons2;
  }();
  var NonEmptyList = function(x) {
    return x;
  };
  var toList = function(v) {
    return new Cons(v.value0, v.value1);
  };
  var listMap = function(f) {
    var chunkedRevMap = function($copy_v) {
      return function($copy_v1) {
        var $tco_var_v = $copy_v;
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v, v1) {
          if (v1 instanceof Cons && (v1.value1 instanceof Cons && v1.value1.value1 instanceof Cons)) {
            $tco_var_v = new Cons(v1, v);
            $copy_v1 = v1.value1.value1.value1;
            return;
          }
          ;
          var unrolledMap = function(v2) {
            if (v2 instanceof Cons && (v2.value1 instanceof Cons && v2.value1.value1 instanceof Nil)) {
              return new Cons(f(v2.value0), new Cons(f(v2.value1.value0), Nil.value));
            }
            ;
            if (v2 instanceof Cons && v2.value1 instanceof Nil) {
              return new Cons(f(v2.value0), Nil.value);
            }
            ;
            return Nil.value;
          };
          var reverseUnrolledMap = function($copy_v2) {
            return function($copy_v3) {
              var $tco_var_v2 = $copy_v2;
              var $tco_done1 = false;
              var $tco_result2;
              function $tco_loop2(v2, v3) {
                if (v2 instanceof Cons && (v2.value0 instanceof Cons && (v2.value0.value1 instanceof Cons && v2.value0.value1.value1 instanceof Cons))) {
                  $tco_var_v2 = v2.value1;
                  $copy_v3 = new Cons(f(v2.value0.value0), new Cons(f(v2.value0.value1.value0), new Cons(f(v2.value0.value1.value1.value0), v3)));
                  return;
                }
                ;
                $tco_done1 = true;
                return v3;
              }
              ;
              while (!$tco_done1) {
                $tco_result2 = $tco_loop2($tco_var_v2, $copy_v3);
              }
              ;
              return $tco_result2;
            };
          };
          $tco_done = true;
          return reverseUnrolledMap(v)(unrolledMap(v1));
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($tco_var_v, $copy_v1);
        }
        ;
        return $tco_result;
      };
    };
    return chunkedRevMap(Nil.value);
  };
  var functorList = {
    map: listMap
  };
  var map3 = /* @__PURE__ */ map(functorList);
  var functorNonEmptyList = /* @__PURE__ */ functorNonEmpty(functorList);
  var foldableList = {
    foldr: function(f) {
      return function(b) {
        var rev3 = function() {
          var go2 = function($copy_v) {
            return function($copy_v1) {
              var $tco_var_v = $copy_v;
              var $tco_done = false;
              var $tco_result;
              function $tco_loop(v, v1) {
                if (v1 instanceof Nil) {
                  $tco_done = true;
                  return v;
                }
                ;
                if (v1 instanceof Cons) {
                  $tco_var_v = new Cons(v1.value0, v);
                  $copy_v1 = v1.value1;
                  return;
                }
                ;
                throw new Error("Failed pattern match at Data.List.Types (line 107, column 7 - line 107, column 23): " + [v.constructor.name, v1.constructor.name]);
              }
              ;
              while (!$tco_done) {
                $tco_result = $tco_loop($tco_var_v, $copy_v1);
              }
              ;
              return $tco_result;
            };
          };
          return go2(Nil.value);
        }();
        var $284 = foldl(foldableList)(flip(f))(b);
        return function($285) {
          return $284(rev3($285));
        };
      };
    },
    foldl: function(f) {
      var go2 = function($copy_b) {
        return function($copy_v) {
          var $tco_var_b = $copy_b;
          var $tco_done1 = false;
          var $tco_result;
          function $tco_loop(b, v) {
            if (v instanceof Nil) {
              $tco_done1 = true;
              return b;
            }
            ;
            if (v instanceof Cons) {
              $tco_var_b = f(b)(v.value0);
              $copy_v = v.value1;
              return;
            }
            ;
            throw new Error("Failed pattern match at Data.List.Types (line 111, column 12 - line 113, column 30): " + [v.constructor.name]);
          }
          ;
          while (!$tco_done1) {
            $tco_result = $tco_loop($tco_var_b, $copy_v);
          }
          ;
          return $tco_result;
        };
      };
      return go2;
    },
    foldMap: function(dictMonoid) {
      var append22 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldl(foldableList)(function(acc) {
          var $286 = append22(acc);
          return function($287) {
            return $286(f($287));
          };
        })(mempty3);
      };
    }
  };
  var foldr2 = /* @__PURE__ */ foldr(foldableList);
  var intercalate2 = /* @__PURE__ */ intercalate(foldableList)(monoidString);
  var semigroupList = {
    append: function(xs) {
      return function(ys) {
        return foldr2(Cons.create)(ys)(xs);
      };
    }
  };
  var append1 = /* @__PURE__ */ append(semigroupList);
  var semigroupNonEmptyList = {
    append: function(v) {
      return function(as$prime) {
        return new NonEmpty(v.value0, append1(v.value1)(toList(as$prime)));
      };
    }
  };
  var showList = function(dictShow) {
    var show16 = show(dictShow);
    return {
      show: function(v) {
        if (v instanceof Nil) {
          return "Nil";
        }
        ;
        return "(" + (intercalate2(" : ")(map3(show16)(v)) + " : Nil)");
      }
    };
  };
  var showNonEmptyList = function(dictShow) {
    var show16 = show(showNonEmpty(dictShow)(showList(dictShow)));
    return {
      show: function(v) {
        return "(NonEmptyList " + (show16(v) + ")");
      }
    };
  };
  var applyList = {
    apply: function(v) {
      return function(v1) {
        if (v instanceof Nil) {
          return Nil.value;
        }
        ;
        if (v instanceof Cons) {
          return append1(map3(v.value0)(v1))(apply(applyList)(v.value1)(v1));
        }
        ;
        throw new Error("Failed pattern match at Data.List.Types (line 157, column 1 - line 159, column 48): " + [v.constructor.name, v1.constructor.name]);
      };
    },
    Functor0: function() {
      return functorList;
    }
  };
  var apply2 = /* @__PURE__ */ apply(applyList);
  var applyNonEmptyList = {
    apply: function(v) {
      return function(v1) {
        return new NonEmpty(v.value0(v1.value0), append1(apply2(v.value1)(new Cons(v1.value0, Nil.value)))(apply2(new Cons(v.value0, v.value1))(v1.value1)));
      };
    },
    Functor0: function() {
      return functorNonEmptyList;
    }
  };
  var altList = {
    alt: append1,
    Functor0: function() {
      return functorList;
    }
  };
  var plusList = /* @__PURE__ */ function() {
    return {
      empty: Nil.value,
      Alt0: function() {
        return altList;
      }
    };
  }();
  var applicativeNonEmptyList = {
    pure: /* @__PURE__ */ function() {
      var $315 = singleton2(plusList);
      return function($316) {
        return NonEmptyList($315($316));
      };
    }(),
    Apply0: function() {
      return applyNonEmptyList;
    }
  };

  // output/Data.Map.Internal/index.js
  var $runtime_lazy = function(name15, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name15 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var Leaf = /* @__PURE__ */ function() {
    function Leaf2() {
    }
    ;
    Leaf2.value = new Leaf2();
    return Leaf2;
  }();
  var Node = /* @__PURE__ */ function() {
    function Node2(value0, value1, value22, value32, value42, value52) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
      this.value3 = value32;
      this.value4 = value42;
      this.value5 = value52;
    }
    ;
    Node2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return function(value32) {
            return function(value42) {
              return function(value52) {
                return new Node2(value0, value1, value22, value32, value42, value52);
              };
            };
          };
        };
      };
    };
    return Node2;
  }();
  var IterLeaf = /* @__PURE__ */ function() {
    function IterLeaf2() {
    }
    ;
    IterLeaf2.value = new IterLeaf2();
    return IterLeaf2;
  }();
  var IterEmit = /* @__PURE__ */ function() {
    function IterEmit2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    IterEmit2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new IterEmit2(value0, value1, value22);
        };
      };
    };
    return IterEmit2;
  }();
  var IterNode = /* @__PURE__ */ function() {
    function IterNode2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    IterNode2.create = function(value0) {
      return function(value1) {
        return new IterNode2(value0, value1);
      };
    };
    return IterNode2;
  }();
  var Split = /* @__PURE__ */ function() {
    function Split2(value0, value1, value22) {
      this.value0 = value0;
      this.value1 = value1;
      this.value2 = value22;
    }
    ;
    Split2.create = function(value0) {
      return function(value1) {
        return function(value22) {
          return new Split2(value0, value1, value22);
        };
      };
    };
    return Split2;
  }();
  var unsafeNode = function(k, v, l, r) {
    if (l instanceof Leaf) {
      if (r instanceof Leaf) {
        return new Node(1, 1, k, v, l, r);
      }
      ;
      if (r instanceof Node) {
        return new Node(1 + r.value0 | 0, 1 + r.value1 | 0, k, v, l, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 700, column 5 - line 704, column 39): " + [r.constructor.name]);
    }
    ;
    if (l instanceof Node) {
      if (r instanceof Leaf) {
        return new Node(1 + l.value0 | 0, 1 + l.value1 | 0, k, v, l, r);
      }
      ;
      if (r instanceof Node) {
        return new Node(1 + function() {
          var $280 = l.value0 > r.value0;
          if ($280) {
            return l.value0;
          }
          ;
          return r.value0;
        }() | 0, (1 + l.value1 | 0) + r.value1 | 0, k, v, l, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 706, column 5 - line 710, column 68): " + [r.constructor.name]);
    }
    ;
    throw new Error("Failed pattern match at Data.Map.Internal (line 698, column 32 - line 710, column 68): " + [l.constructor.name]);
  };
  var toMapIter = /* @__PURE__ */ function() {
    return flip(IterNode.create)(IterLeaf.value);
  }();
  var stepWith = function(f) {
    return function(next2) {
      return function(done) {
        var go2 = function($copy_v) {
          var $tco_done = false;
          var $tco_result;
          function $tco_loop(v) {
            if (v instanceof IterLeaf) {
              $tco_done = true;
              return done(unit);
            }
            ;
            if (v instanceof IterEmit) {
              $tco_done = true;
              return next2(v.value0, v.value1, v.value2);
            }
            ;
            if (v instanceof IterNode) {
              $copy_v = f(v.value1)(v.value0);
              return;
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 938, column 8 - line 944, column 20): " + [v.constructor.name]);
          }
          ;
          while (!$tco_done) {
            $tco_result = $tco_loop($copy_v);
          }
          ;
          return $tco_result;
        };
        return go2;
      };
    };
  };
  var singleton3 = function(k) {
    return function(v) {
      return new Node(1, 1, k, v, Leaf.value, Leaf.value);
    };
  };
  var unsafeBalancedNode = /* @__PURE__ */ function() {
    var height8 = function(v) {
      if (v instanceof Leaf) {
        return 0;
      }
      ;
      if (v instanceof Node) {
        return v.value0;
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 755, column 12 - line 757, column 26): " + [v.constructor.name]);
    };
    var rotateLeft = function(k, v, l, rk, rv, rl, rr) {
      if (rl instanceof Node && rl.value0 > height8(rr)) {
        return unsafeNode(rl.value2, rl.value3, unsafeNode(k, v, l, rl.value4), unsafeNode(rk, rv, rl.value5, rr));
      }
      ;
      return unsafeNode(rk, rv, unsafeNode(k, v, l, rl), rr);
    };
    var rotateRight = function(k, v, lk, lv, ll, lr, r) {
      if (lr instanceof Node && height8(ll) <= lr.value0) {
        return unsafeNode(lr.value2, lr.value3, unsafeNode(lk, lv, ll, lr.value4), unsafeNode(k, v, lr.value5, r));
      }
      ;
      return unsafeNode(lk, lv, ll, unsafeNode(k, v, lr, r));
    };
    return function(k, v, l, r) {
      if (l instanceof Leaf) {
        if (r instanceof Leaf) {
          return singleton3(k)(v);
        }
        ;
        if (r instanceof Node && r.value0 > 1) {
          return rotateLeft(k, v, l, r.value2, r.value3, r.value4, r.value5);
        }
        ;
        return unsafeNode(k, v, l, r);
      }
      ;
      if (l instanceof Node) {
        if (r instanceof Node) {
          if (r.value0 > (l.value0 + 1 | 0)) {
            return rotateLeft(k, v, l, r.value2, r.value3, r.value4, r.value5);
          }
          ;
          if (l.value0 > (r.value0 + 1 | 0)) {
            return rotateRight(k, v, l.value2, l.value3, l.value4, l.value5, r);
          }
          ;
        }
        ;
        if (r instanceof Leaf && l.value0 > 1) {
          return rotateRight(k, v, l.value2, l.value3, l.value4, l.value5, r);
        }
        ;
        return unsafeNode(k, v, l, r);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 715, column 40 - line 736, column 34): " + [l.constructor.name]);
    };
  }();
  var $lazy_unsafeSplit = /* @__PURE__ */ $runtime_lazy("unsafeSplit", "Data.Map.Internal", function() {
    return function(comp, k, m) {
      if (m instanceof Leaf) {
        return new Split(Nothing.value, Leaf.value, Leaf.value);
      }
      ;
      if (m instanceof Node) {
        var v = comp(k)(m.value2);
        if (v instanceof LT) {
          var v1 = $lazy_unsafeSplit(791)(comp, k, m.value4);
          return new Split(v1.value0, v1.value1, unsafeBalancedNode(m.value2, m.value3, v1.value2, m.value5));
        }
        ;
        if (v instanceof GT) {
          var v1 = $lazy_unsafeSplit(794)(comp, k, m.value5);
          return new Split(v1.value0, unsafeBalancedNode(m.value2, m.value3, m.value4, v1.value1), v1.value2);
        }
        ;
        if (v instanceof EQ) {
          return new Split(new Just(m.value3), m.value4, m.value5);
        }
        ;
        throw new Error("Failed pattern match at Data.Map.Internal (line 789, column 5 - line 797, column 30): " + [v.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 785, column 34 - line 797, column 30): " + [m.constructor.name]);
    };
  });
  var unsafeSplit = /* @__PURE__ */ $lazy_unsafeSplit(784);
  var $lazy_unsafeUnionWith = /* @__PURE__ */ $runtime_lazy("unsafeUnionWith", "Data.Map.Internal", function() {
    return function(comp, app, l, r) {
      if (l instanceof Leaf) {
        return r;
      }
      ;
      if (r instanceof Leaf) {
        return l;
      }
      ;
      if (r instanceof Node) {
        var v = unsafeSplit(comp, r.value2, l);
        var l$prime = $lazy_unsafeUnionWith(807)(comp, app, v.value1, r.value4);
        var r$prime = $lazy_unsafeUnionWith(808)(comp, app, v.value2, r.value5);
        if (v.value0 instanceof Just) {
          return unsafeBalancedNode(r.value2, app(v.value0.value0)(r.value3), l$prime, r$prime);
        }
        ;
        if (v.value0 instanceof Nothing) {
          return unsafeBalancedNode(r.value2, r.value3, l$prime, r$prime);
        }
        ;
        throw new Error("Failed pattern match at Data.Map.Internal (line 809, column 5 - line 813, column 46): " + [v.value0.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Data.Map.Internal (line 802, column 42 - line 813, column 46): " + [l.constructor.name, r.constructor.name]);
    };
  });
  var unsafeUnionWith = /* @__PURE__ */ $lazy_unsafeUnionWith(801);
  var unionWith = function(dictOrd) {
    var compare3 = compare(dictOrd);
    return function(app) {
      return function(m1) {
        return function(m2) {
          return unsafeUnionWith(compare3, app, m1, m2);
        };
      };
    };
  };
  var union = function(dictOrd) {
    return unionWith(dictOrd)($$const);
  };
  var lookup = function(dictOrd) {
    var compare3 = compare(dictOrd);
    return function(k) {
      var go2 = function($copy_v) {
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(v) {
          if (v instanceof Leaf) {
            $tco_done = true;
            return Nothing.value;
          }
          ;
          if (v instanceof Node) {
            var v1 = compare3(k)(v.value2);
            if (v1 instanceof LT) {
              $copy_v = v.value4;
              return;
            }
            ;
            if (v1 instanceof GT) {
              $copy_v = v.value5;
              return;
            }
            ;
            if (v1 instanceof EQ) {
              $tco_done = true;
              return new Just(v.value3);
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 283, column 7 - line 286, column 22): " + [v1.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 280, column 8 - line 286, column 22): " + [v.constructor.name]);
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($copy_v);
        }
        ;
        return $tco_result;
      };
      return go2;
    };
  };
  var iterMapL = /* @__PURE__ */ function() {
    var go2 = function($copy_iter) {
      return function($copy_v) {
        var $tco_var_iter = $copy_iter;
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(iter, v) {
          if (v instanceof Leaf) {
            $tco_done = true;
            return iter;
          }
          ;
          if (v instanceof Node) {
            if (v.value5 instanceof Leaf) {
              $tco_var_iter = new IterEmit(v.value2, v.value3, iter);
              $copy_v = v.value4;
              return;
            }
            ;
            $tco_var_iter = new IterEmit(v.value2, v.value3, new IterNode(v.value5, iter));
            $copy_v = v.value4;
            return;
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 949, column 13 - line 956, column 48): " + [v.constructor.name]);
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($tco_var_iter, $copy_v);
        }
        ;
        return $tco_result;
      };
    };
    return go2;
  }();
  var stepAscCps = /* @__PURE__ */ stepWith(iterMapL);
  var stepUnfoldr = /* @__PURE__ */ function() {
    var step2 = function(k, v, next2) {
      return new Just(new Tuple(new Tuple(k, v), next2));
    };
    return stepAscCps(step2)(function(v) {
      return Nothing.value;
    });
  }();
  var toUnfoldable = function(dictUnfoldable) {
    var $784 = unfoldr(dictUnfoldable)(stepUnfoldr);
    return function($785) {
      return $784(toMapIter($785));
    };
  };
  var insert = function(dictOrd) {
    var compare3 = compare(dictOrd);
    return function(k) {
      return function(v) {
        var go2 = function(v1) {
          if (v1 instanceof Leaf) {
            return singleton3(k)(v);
          }
          ;
          if (v1 instanceof Node) {
            var v2 = compare3(k)(v1.value2);
            if (v2 instanceof LT) {
              return unsafeBalancedNode(v1.value2, v1.value3, go2(v1.value4), v1.value5);
            }
            ;
            if (v2 instanceof GT) {
              return unsafeBalancedNode(v1.value2, v1.value3, v1.value4, go2(v1.value5));
            }
            ;
            if (v2 instanceof EQ) {
              return new Node(v1.value0, v1.value1, k, v, v1.value4, v1.value5);
            }
            ;
            throw new Error("Failed pattern match at Data.Map.Internal (line 469, column 7 - line 472, column 35): " + [v2.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 466, column 8 - line 472, column 35): " + [v1.constructor.name]);
        };
        return go2;
      };
    };
  };
  var empty2 = /* @__PURE__ */ function() {
    return Leaf.value;
  }();
  var fromFoldable = function(dictOrd) {
    var insert1 = insert(dictOrd);
    return function(dictFoldable) {
      return foldl(dictFoldable)(function(m) {
        return function(v) {
          return insert1(v.value0)(v.value1)(m);
        };
      })(empty2);
    };
  };

  // output/Data.String.Common/foreign.js
  var split = function(sep) {
    return function(s) {
      return s.split(sep);
    };
  };
  var toLower = function(s) {
    return s.toLowerCase();
  };
  var toUpper = function(s) {
    return s.toUpperCase();
  };
  var trim = function(s) {
    return s.trim();
  };
  var joinWith = function(s) {
    return function(xs) {
      return xs.join(s);
    };
  };

  // output/Data.String.Common/index.js
  var $$null2 = function(s) {
    return s === "";
  };

  // output/Effect.Exception/foreign.js
  function error(msg) {
    return new Error(msg);
  }
  function errorWithName(msg) {
    return function(name15) {
      const e = new Error(msg);
      e.name = name15;
      return e;
    };
  }
  function message(e) {
    return e.message;
  }
  function name(e) {
    return e.name || "Error";
  }
  function throwException(e) {
    return function() {
      throw e;
    };
  }
  function catchException(c) {
    return function(t) {
      return function() {
        try {
          return t();
        } catch (e) {
          if (e instanceof Error || Object.prototype.toString.call(e) === "[object Error]") {
            return c(e)();
          } else {
            return c(new Error(e.toString()))();
          }
        }
      };
    };
  }

  // output/Effect/foreign.js
  var pureE = function(a) {
    return function() {
      return a;
    };
  };
  var bindE = function(a) {
    return function(f) {
      return function() {
        return f(a())();
      };
    };
  };

  // output/Control.Monad/index.js
  var liftM1 = function(dictMonad) {
    var bind20 = bind(dictMonad.Bind1());
    var pure24 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a) {
        return bind20(a)(function(a$prime) {
          return pure24(f(a$prime));
        });
      };
    };
  };
  var ap = function(dictMonad) {
    var bind20 = bind(dictMonad.Bind1());
    var pure24 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a) {
        return bind20(f)(function(f$prime) {
          return bind20(a)(function(a$prime) {
            return pure24(f$prime(a$prime));
          });
        });
      };
    };
  };

  // output/Effect/index.js
  var $runtime_lazy2 = function(name15, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name15 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var monadEffect = {
    Applicative0: function() {
      return applicativeEffect;
    },
    Bind1: function() {
      return bindEffect;
    }
  };
  var bindEffect = {
    bind: bindE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var applicativeEffect = {
    pure: pureE,
    Apply0: function() {
      return $lazy_applyEffect(0);
    }
  };
  var $lazy_functorEffect = /* @__PURE__ */ $runtime_lazy2("functorEffect", "Effect", function() {
    return {
      map: liftA1(applicativeEffect)
    };
  });
  var $lazy_applyEffect = /* @__PURE__ */ $runtime_lazy2("applyEffect", "Effect", function() {
    return {
      apply: ap(monadEffect),
      Functor0: function() {
        return $lazy_functorEffect(0);
      }
    };
  });
  var functorEffect = /* @__PURE__ */ $lazy_functorEffect(20);
  var applyEffect = /* @__PURE__ */ $lazy_applyEffect(23);

  // output/Effect.Exception/index.js
  var pure2 = /* @__PURE__ */ pure(applicativeEffect);
  var map4 = /* @__PURE__ */ map(functorEffect);
  var $$try = function(action2) {
    return catchException(function($3) {
      return pure2(Left.create($3));
    })(map4(Right.create)(action2));
  };

  // output/Main.MinsiError/index.js
  var map5 = /* @__PURE__ */ map(functorArray);
  var toUnfoldable2 = /* @__PURE__ */ toUnfoldable(unfoldableArray);
  var show2 = /* @__PURE__ */ show(showInt);
  var apply3 = /* @__PURE__ */ apply(applyFn);
  var HTMLElementNotFound = /* @__PURE__ */ function() {
    function HTMLElementNotFound2(value0) {
      this.value0 = value0;
    }
    ;
    HTMLElementNotFound2.create = function(value0) {
      return new HTMLElementNotFound2(value0);
    };
    return HTMLElementNotFound2;
  }();
  var MissingDependenciesError = /* @__PURE__ */ function() {
    function MissingDependenciesError2(value0) {
      this.value0 = value0;
    }
    ;
    MissingDependenciesError2.create = function(value0) {
      return new MissingDependenciesError2(value0);
    };
    return MissingDependenciesError2;
  }();
  var InvalidInput = /* @__PURE__ */ function() {
    function InvalidInput2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    InvalidInput2.create = function(value0) {
      return function(value1) {
        return new InvalidInput2(value0, value1);
      };
    };
    return InvalidInput2;
  }();
  var InvalidInputs = /* @__PURE__ */ function() {
    function InvalidInputs2(value0) {
      this.value0 = value0;
    }
    ;
    InvalidInputs2.create = function(value0) {
      return new InvalidInputs2(value0);
    };
    return InvalidInputs2;
  }();
  var JSONParsingError = /* @__PURE__ */ function() {
    function JSONParsingError2(value0) {
      this.value0 = value0;
    }
    ;
    JSONParsingError2.create = function(value0) {
      return new JSONParsingError2(value0);
    };
    return JSONParsingError2;
  }();
  var ErrorResponse = /* @__PURE__ */ function() {
    function ErrorResponse2(value0) {
      this.value0 = value0;
    }
    ;
    ErrorResponse2.create = function(value0) {
      return new ErrorResponse2(value0);
    };
    return ErrorResponse2;
  }();
  var ComputeFailed = /* @__PURE__ */ function() {
    function ComputeFailed2(value0) {
      this.value0 = value0;
    }
    ;
    ComputeFailed2.create = function(value0) {
      return new ComputeFailed2(value0);
    };
    return ComputeFailed2;
  }();
  var showMinsiError = {
    show: function(v) {
      if (v instanceof HTMLElementNotFound) {
        return "HTML Element couldn't be loaded: " + v.value0;
      }
      ;
      if (v instanceof MissingDependenciesError) {
        return "Dependency Error: <br>" + joinWith("<br>")(v.value0);
      }
      ;
      if (v instanceof InvalidInput) {
        return "[" + (v.value0 + ("] Invalid Input: " + v.value1));
      }
      ;
      if (v instanceof InvalidInputs) {
        var errorMessages = map5(function(v1) {
          return "[" + (v1.value0 + ("] " + v1.value1));
        })(toUnfoldable2(v.value0));
        return joinWith("<br>")(errorMessages);
      }
      ;
      if (v instanceof JSONParsingError) {
        return "Error while parsing: " + v.value0;
      }
      ;
      if (v instanceof ErrorResponse) {
        return "Got a Response with status \u2260 200: " + show2(v.value0);
      }
      ;
      if (v instanceof ComputeFailed) {
        return "Compute failed: " + v.value0;
      }
      ;
      throw new Error("Failed pattern match at Main.MinsiError (line 20, column 10 - line 34, column 51): " + [v.constructor.name]);
    }
  };
  var minsiErrorName = function(v) {
    if (v instanceof HTMLElementNotFound) {
      return "HTMLElementNotFound";
    }
    ;
    if (v instanceof MissingDependenciesError) {
      return "MissingDependenciesError";
    }
    ;
    if (v instanceof InvalidInput) {
      return "InvalidInput";
    }
    ;
    if (v instanceof InvalidInputs) {
      return "InvalidInputs";
    }
    ;
    if (v instanceof JSONParsingError) {
      return "JSONParsingError";
    }
    ;
    if (v instanceof ErrorResponse) {
      return "ErrorResponse";
    }
    ;
    if (v instanceof ComputeFailed) {
      return "ComputeFailed";
    }
    ;
    throw new Error("Failed pattern match at Main.MinsiError (line 40, column 1 - line 40, column 39): " + [v.constructor.name]);
  };
  var throwMinsiError = /* @__PURE__ */ function() {
    var $34 = apply3(apply3($$const(errorWithName))(show(showMinsiError)))(minsiErrorName);
    return function($35) {
      return throwException($34($35));
    };
  }();
  var isCriticalError = function(e) {
    var v = name(e);
    if (v === "HTMLElementNotFound") {
      return false;
    }
    ;
    if (v === "MissingDependenciesError") {
      return true;
    }
    ;
    if (v === "InvalidInput") {
      return false;
    }
    ;
    if (v === "InvalidInputs") {
      return false;
    }
    ;
    if (v === "JSONParsingError") {
      return true;
    }
    ;
    if (v === "ErrorResponse") {
      return true;
    }
    ;
    if (v === "ComputeFailed") {
      return true;
    }
    ;
    return false;
  };

  // output/Web.DOM.NonElementParentNode/foreign.js
  function _getElementById(id2) {
    return function(node) {
      return function() {
        return node.getElementById(id2);
      };
    };
  }

  // output/Data.Nullable/foreign.js
  function nullable(a, r, f) {
    return a == null ? r : f(a);
  }

  // output/Data.Nullable/index.js
  var toMaybe = function(n) {
    return nullable(n, Nothing.value, Just.create);
  };

  // output/Web.DOM.NonElementParentNode/index.js
  var map6 = /* @__PURE__ */ map(functorEffect);
  var getElementById = function(eid) {
    var $2 = map6(toMaybe);
    var $3 = _getElementById(eid);
    return function($4) {
      return $2($3($4));
    };
  };

  // output/Components.HTMLComponentsLoader/index.js
  var bind1 = /* @__PURE__ */ bind(bindMaybe);
  var loadHtmlElement = function(id2) {
    return function(f) {
      return function(doc) {
        return function __do5() {
          var maybeComponent = getElementById(id2)(doc)();
          var maybeComponentElement = bind1(maybeComponent)(f);
          if (maybeComponentElement instanceof Nothing) {
            return throwMinsiError(new HTMLElementNotFound(id2))();
          }
          ;
          if (maybeComponentElement instanceof Just) {
            return maybeComponentElement.value0;
          }
          ;
          throw new Error("Failed pattern match at Components.HTMLComponentsLoader (line 15, column 3 - line 17, column 33): " + [maybeComponentElement.constructor.name]);
        };
      };
    };
  };

  // output/Components.HtmlIds/index.js
  var youtubeUrlId = "youtubeUrl";
  var videoSourceRowId = "videoSourceRowId";
  var videoSourceId = "videoSource";
  var videoRowId = "videoRowId";
  var titleId = "title";
  var subtitlesRowId = "subtitlesRowId";
  var subtitleTableId = "subtitleTable";
  var subtitleRow = "subtitleRow";
  var setSubtitleStartButtonId = "setSubtitleStartButton";
  var setSubtitleEndButtonId = "setSubtitleEndButton";
  var setCutStartButton = "setCutStartButton";
  var setCutEndButton = "setCutEndButton";
  var reverseLoopGifId = "reverseLoopGif";
  var resultVideoId = "resultVideo";
  var resultPreviewId = "youtubeResultPreview";
  var playbackPositionYoutubeId = "playbackPositionYoutube";
  var playbackPositionResultVideoId = "playbackPositionResultVideo";
  var playbackPositionResultRowId = "playbackPositionResultRowId";
  var outputFilenameId = "outputFilename";
  var minsiLogId = "minsiLog";
  var minsiErrorModalId = "minsiErrorModal";
  var minsiErrorModalContentId = "minsiErrorModalContent";
  var loadingModalId = "loadingModal";
  var keyboardShortcutsModalId = "keyboardShortcutsModal";
  var keyboardShortcutsButtonId = "keyboardShortcutsButton";
  var cutStartValueId = "cutStartValue";
  var cutStartId = "cutStart";
  var cutEndValueId = "cutEndValue";
  var cutEndId = "cutEnd";
  var artistId = "artist";
  var applyId = "applyButton";
  var addSubtitleId = "addSubtitleButton";

  // output/Control.Monad.Error.Class/index.js
  var throwError = function(dict) {
    return dict.throwError;
  };
  var monadThrowEffect = {
    throwError: throwException,
    Monad0: function() {
      return monadEffect;
    }
  };
  var monadErrorEffect = {
    catchError: /* @__PURE__ */ flip(catchException),
    MonadThrow0: function() {
      return monadThrowEffect;
    }
  };
  var catchError = function(dict) {
    return dict.catchError;
  };
  var $$try2 = function(dictMonadError) {
    var catchError1 = catchError(dictMonadError);
    var Monad0 = dictMonadError.MonadThrow0().Monad0();
    var map24 = map(Monad0.Bind1().Apply0().Functor0());
    var pure24 = pure(Monad0.Applicative0());
    return function(a) {
      return catchError1(map24(Right.create)(a))(function($52) {
        return pure24(Left.create($52));
      });
    };
  };

  // output/Web.Internal.FFI/foreign.js
  function _unsafeReadProtoTagged(nothing, just, name15, value12) {
    if (typeof window !== "undefined") {
      var ty = window[name15];
      if (ty != null && value12 instanceof ty) {
        return just(value12);
      }
    }
    var obj = value12;
    while (obj != null) {
      var proto = Object.getPrototypeOf(obj);
      var constructorName = proto.constructor.name;
      if (constructorName === name15) {
        return just(value12);
      } else if (constructorName === "Object") {
        return nothing;
      }
      obj = proto;
    }
    return nothing;
  }

  // output/Web.Internal.FFI/index.js
  var unsafeReadProtoTagged = function(name15) {
    return function(value12) {
      return _unsafeReadProtoTagged(Nothing.value, Just.create, name15, value12);
    };
  };

  // output/Web.HTML.HTMLButtonElement/index.js
  var toElement = unsafeCoerce2;
  var fromEventTarget = /* @__PURE__ */ unsafeReadProtoTagged("HTMLButtonElement");
  var fromElement = /* @__PURE__ */ unsafeReadProtoTagged("HTMLButtonElement");

  // output/Web.HTML.HTMLDivElement/index.js
  var toNode = unsafeCoerce2;
  var toElement2 = unsafeCoerce2;
  var fromElement2 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLDivElement");

  // output/Web.HTML.HTMLIFrameElement/index.js
  var fromElement3 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLIFrameElement");

  // output/Web.HTML.HTMLInputElement/foreign.js
  function checked(input2) {
    return function() {
      return input2.checked;
    };
  }
  function setMax(max7) {
    return function(input2) {
      return function() {
        input2.max = max7;
      };
    };
  }
  function value2(input2) {
    return function() {
      return input2.value;
    };
  }
  function setValue2(value12) {
    return function(input2) {
      return function() {
        input2.value = value12;
      };
    };
  }
  function valueAsNumber(input2) {
    return function() {
      return input2.valueAsNumber;
    };
  }

  // output/Web.HTML.HTMLInputElement/index.js
  var toElement3 = unsafeCoerce2;
  var fromElement4 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLInputElement");

  // output/Web.HTML.HTMLSelectElement/foreign.js
  function value3(select3) {
    return function() {
      return select3.value;
    };
  }

  // output/Web.HTML.HTMLSelectElement/index.js
  var toElement4 = unsafeCoerce2;
  var fromElement5 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLSelectElement");

  // output/Web.HTML.HTMLSpanElement/index.js
  var toNode2 = unsafeCoerce2;
  var fromElement6 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLSpanElement");

  // output/Web.HTML.HTMLTableElement/foreign.js
  function tBodies(table) {
    return function() {
      return table.tBodies;
    };
  }

  // output/Web.HTML.HTMLTableElement/index.js
  var fromElement7 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTableElement");

  // output/Web.HTML.HTMLTemplateElement/foreign.js
  function content(template) {
    return function() {
      return template.content;
    };
  }

  // output/Web.HTML.HTMLTemplateElement/index.js
  var fromElement8 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTemplateElement");

  // output/Web.HTML.HTMLVideoElement/index.js
  var toHTMLMediaElement = unsafeCoerce2;
  var fromElement9 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLVideoElement");

  // output/Components.HtmlComponents/index.js
  var catchError2 = /* @__PURE__ */ catchError(monadErrorEffect);
  var ResultPreviewDiv = /* @__PURE__ */ function() {
    function ResultPreviewDiv2(value0) {
      this.value0 = value0;
    }
    ;
    ResultPreviewDiv2.create = function(value0) {
      return new ResultPreviewDiv2(value0);
    };
    return ResultPreviewDiv2;
  }();
  var ResultPreviewIframe = /* @__PURE__ */ function() {
    function ResultPreviewIframe2(value0) {
      this.value0 = value0;
    }
    ;
    ResultPreviewIframe2.create = function(value0) {
      return new ResultPreviewIframe2(value0);
    };
    return ResultPreviewIframe2;
  }();
  var HtmlVisualElements = /* @__PURE__ */ function() {
    function HtmlVisualElements2(value0) {
      this.value0 = value0;
    }
    ;
    HtmlVisualElements2.create = function(value0) {
      return new HtmlVisualElements2(value0);
    };
    return HtmlVisualElements2;
  }();
  var HtmlInputs = /* @__PURE__ */ function() {
    function HtmlInputs2(value0) {
      this.value0 = value0;
    }
    ;
    HtmlInputs2.create = function(value0) {
      return new HtmlInputs2(value0);
    };
    return HtmlInputs2;
  }();
  var loadVideoSource = /* @__PURE__ */ loadHtmlElement(videoSourceId)(fromElement5);
  var loadVideo = function(id2) {
    return loadHtmlElement(id2)(fromElement9);
  };
  var loadTemplate = function(id2) {
    return loadHtmlElement(id2)(fromElement8);
  };
  var loadTable = function(id2) {
    return loadHtmlElement(id2)(fromElement7);
  };
  var loadSpan = function(id2) {
    return loadHtmlElement(id2)(fromElement6);
  };
  var loadInput = function(id2) {
    return loadHtmlElement(id2)(fromElement4);
  };
  var loadDiv = function(id2) {
    return loadHtmlElement(id2)(fromElement2);
  };
  var loadHtmlVisualElements = function(doc) {
    return function __do5() {
      var videoSourceRow = loadDiv(videoSourceRowId)(doc)();
      var videoRow = loadDiv(videoRowId)(doc)();
      var subtitlesRow = loadDiv(subtitlesRowId)(doc)();
      var playbackPositionResultRow = loadDiv(playbackPositionResultRowId)(doc)();
      return new HtmlVisualElements({
        videoSourceRow,
        videoRow,
        subtitlesRow,
        playbackPositionResultRow
      });
    };
  };
  var loadResultPreview = function(doc) {
    return catchError2(function __do5() {
      var div2 = loadDiv(resultPreviewId)(doc)();
      return new ResultPreviewDiv(div2);
    })(function(v) {
      return function __do5() {
        var iframe = loadHtmlElement(resultPreviewId)(fromElement3)(doc)();
        return new ResultPreviewIframe(iframe);
      };
    });
  };
  var loadCutRange = function(doc) {
    return function __do5() {
      var cutStart = loadHtmlElement(cutStartId)(fromElement4)(doc)();
      var cutEnd = loadHtmlElement(cutEndId)(fromElement4)(doc)();
      return new Tuple(cutStart, cutEnd);
    };
  };
  var loadButton = function(id2) {
    return loadHtmlElement(id2)(fromElement);
  };
  var loadHtmlInputs = function(doc) {
    return function __do5() {
      var rangeTuple = loadCutRange(doc)();
      var youtubeUrl = loadInput(youtubeUrlId)(doc)();
      var filename = loadInput(outputFilenameId)(doc)();
      var reverseLoop = loadInput(reverseLoopGifId)(doc)();
      var artist = loadInput(artistId)(doc)();
      var title2 = loadInput(titleId)(doc)();
      var applyButton = loadButton(applyId)(doc)();
      var videoSource = loadVideoSource(doc)();
      var setCutStartButton2 = loadButton(setCutStartButton)(doc)();
      var setCutEndButton2 = loadButton(setCutEndButton)(doc)();
      var subtitleTable = loadTable(subtitleTableId)(doc)();
      var addSubtitleButton = loadButton(addSubtitleId)(doc)();
      var setSubtitleStartButton = loadButton(setSubtitleStartButtonId)(doc)();
      var setSubtitleEndButton = loadButton(setSubtitleEndButtonId)(doc)();
      var subtitleRow2 = loadTemplate(subtitleRow)(doc)();
      return new HtmlInputs({
        cutStart: fst(rangeTuple),
        cutEnd: snd(rangeTuple),
        youtubeUrl,
        filename,
        reverseLoop,
        artist,
        title: title2,
        applyButton,
        videoSource,
        setCutStartButton: setCutStartButton2,
        setCutEndButton: setCutEndButton2,
        subtitleTable,
        addSubtitleButton,
        setSubtitleStartButton,
        setSubtitleEndButton,
        subtitleRow: subtitleRow2
      });
    };
  };
  var loadHtmlOutputs = function(doc) {
    return function __do5() {
      var resultPreview = loadResultPreview(doc)();
      var minsiLog = loadDiv(minsiLogId)(doc)();
      var playbackPositionYoutube = loadSpan(playbackPositionYoutubeId)(doc)();
      var playbackPositionResultVideo = loadSpan(playbackPositionResultVideoId)(doc)();
      var cutStartValue = loadHtmlElement(cutStartValueId)(fromElement4)(doc)();
      var cutEndValue = loadHtmlElement(cutEndValueId)(fromElement4)(doc)();
      var loadingModal = loadDiv(loadingModalId)(doc)();
      var minsiErrorModal = loadDiv(minsiErrorModalId)(doc)();
      var resultVideo = loadVideo(resultVideoId)(doc)();
      var keyboardShortcutsButton = loadButton(keyboardShortcutsButtonId)(doc)();
      return {
        resultPreview,
        minsiLog,
        playbackPositionYoutube,
        playbackPositionResultVideo,
        cutStartValue,
        cutEndValue,
        loadingModal,
        minsiErrorModal,
        resultVideo,
        keyboardShortcutsButton
      };
    };
  };
  var loadComponents = function(doc) {
    return function __do5() {
      var inputs = loadHtmlInputs(doc)();
      var outputs = loadHtmlOutputs(doc)();
      var visualElements = loadHtmlVisualElements(doc)();
      return {
        htmlInputs: inputs,
        htmlOutputs: outputs,
        htmlVisualElements: visualElements
      };
    };
  };

  // output/Web.HTML/foreign.js
  var windowImpl = function() {
    return window;
  };

  // output/Web.HTML.HTMLDocument/index.js
  var toNonElementParentNode = unsafeCoerce2;
  var toEventTarget = unsafeCoerce2;
  var toDocument = unsafeCoerce2;

  // output/Effect.Uncurried/foreign.js
  var mkEffectFn1 = function mkEffectFn12(fn) {
    return function(x) {
      return fn(x)();
    };
  };
  var runEffectFn1 = function runEffectFn12(fn) {
    return function(a) {
      return function() {
        return fn(a);
      };
    };
  };
  var runEffectFn2 = function runEffectFn22(fn) {
    return function(a) {
      return function(b) {
        return function() {
          return fn(a, b);
        };
      };
    };
  };

  // output/Web.HTML.HTMLLIElement/index.js
  var toElement5 = unsafeCoerce2;
  var fromElement10 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLLIElement");

  // output/Web.HTML.HTMLMediaElement/foreign.js
  function setSrc5(src9) {
    return function(media4) {
      return function() {
        media4.src = src9;
      };
    };
  }
  function load(media4) {
    return function() {
      return media4.load();
    };
  }
  function currentTime(media4) {
    return function() {
      return media4.currentTime;
    };
  }
  function setCurrentTime(currentTime2) {
    return function(media4) {
      return function() {
        media4.currentTime = currentTime2;
      };
    };
  }
  function duration(media4) {
    return function() {
      return media4.duration;
    };
  }
  function paused(media4) {
    return function() {
      return media4.paused;
    };
  }
  function play(media4) {
    return function() {
      media4.play();
    };
  }
  function pause(media4) {
    return function() {
      media4.pause();
    };
  }

  // output/Web.HTML.HTMLTableCellElement/index.js
  var toElement6 = unsafeCoerce2;
  var fromElement11 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTableCellElement");

  // output/Web.HTML.HTMLTableRowElement/foreign.js
  function cells(row) {
    return function() {
      return row.cells;
    };
  }

  // output/Web.HTML.HTMLTableRowElement/index.js
  var toNode3 = unsafeCoerce2;
  var toElement7 = unsafeCoerce2;
  var fromElement12 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTableRowElement");

  // output/Web.HTML.HTMLTableSectionElement/foreign.js
  function rows2(section) {
    return function() {
      return section.rows;
    };
  }

  // output/Web.HTML.HTMLTableSectionElement/index.js
  var toNode4 = unsafeCoerce2;
  var fromElement13 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTableSectionElement");

  // output/Web.HTML.HTMLTextAreaElement/foreign.js
  function value11(textarea) {
    return function() {
      return textarea.value;
    };
  }

  // output/Web.HTML.HTMLTextAreaElement/index.js
  var fromElement14 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLTextAreaElement");

  // output/Web.HTML.HTMLUListElement/index.js
  var toElement8 = unsafeCoerce2;
  var fromElement15 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLUListElement");

  // output/Web.HTML.Location/foreign.js
  function setHash(hash2) {
    return function(location2) {
      return function() {
        location2.hash = hash2;
      };
    };
  }

  // output/Web.HTML.Window/foreign.js
  function document2(window2) {
    return function() {
      return window2.document;
    };
  }
  function location(window2) {
    return function() {
      return window2.location;
    };
  }
  function alert(str) {
    return function(window2) {
      return function() {
        window2.alert(str);
      };
    };
  }

  // output/Components.Window/index.js
  var raiseErrorAlert = function(msg) {
    return function __do5() {
      var w = windowImpl();
      return alert("\u{1F63E}!!! ERROR !!! \u{1F63E}\n" + msg)(w)();
    };
  };
  var getDocument = function __do() {
    var w = windowImpl();
    var d = document2(w)();
    return toNonElementParentNode(d);
  };

  // output/Effect.Aff/foreign.js
  var Aff = function() {
    var EMPTY = {};
    var PURE = "Pure";
    var THROW = "Throw";
    var CATCH = "Catch";
    var SYNC = "Sync";
    var ASYNC = "Async";
    var BIND = "Bind";
    var BRACKET = "Bracket";
    var FORK = "Fork";
    var SEQ = "Sequential";
    var MAP = "Map";
    var APPLY = "Apply";
    var ALT = "Alt";
    var CONS = "Cons";
    var RESUME = "Resume";
    var RELEASE = "Release";
    var FINALIZER = "Finalizer";
    var FINALIZED = "Finalized";
    var FORKED = "Forked";
    var FIBER = "Fiber";
    var THUNK = "Thunk";
    function Aff2(tag, _1, _2, _3) {
      this.tag = tag;
      this._1 = _1;
      this._2 = _2;
      this._3 = _3;
    }
    function AffCtr(tag) {
      var fn = function(_1, _2, _3) {
        return new Aff2(tag, _1, _2, _3);
      };
      fn.tag = tag;
      return fn;
    }
    function nonCanceler2(error3) {
      return new Aff2(PURE, void 0);
    }
    function runEff(eff) {
      try {
        eff();
      } catch (error3) {
        setTimeout(function() {
          throw error3;
        }, 0);
      }
    }
    function runSync(left, right, eff) {
      try {
        return right(eff());
      } catch (error3) {
        return left(error3);
      }
    }
    function runAsync(left, eff, k) {
      try {
        return eff(k)();
      } catch (error3) {
        k(left(error3))();
        return nonCanceler2;
      }
    }
    var Scheduler = function() {
      var limit = 1024;
      var size5 = 0;
      var ix = 0;
      var queue = new Array(limit);
      var draining = false;
      function drain() {
        var thunk;
        draining = true;
        while (size5 !== 0) {
          size5--;
          thunk = queue[ix];
          queue[ix] = void 0;
          ix = (ix + 1) % limit;
          thunk();
        }
        draining = false;
      }
      return {
        isDraining: function() {
          return draining;
        },
        enqueue: function(cb) {
          var i, tmp;
          if (size5 === limit) {
            tmp = draining;
            drain();
            draining = tmp;
          }
          queue[(ix + size5) % limit] = cb;
          size5++;
          if (!draining) {
            drain();
          }
        }
      };
    }();
    function Supervisor(util) {
      var fibers = {};
      var fiberId = 0;
      var count = 0;
      return {
        register: function(fiber) {
          var fid = fiberId++;
          fiber.onComplete({
            rethrow: true,
            handler: function(result) {
              return function() {
                count--;
                delete fibers[fid];
              };
            }
          })();
          fibers[fid] = fiber;
          count++;
        },
        isEmpty: function() {
          return count === 0;
        },
        killAll: function(killError, cb) {
          return function() {
            if (count === 0) {
              return cb();
            }
            var killCount = 0;
            var kills = {};
            function kill(fid) {
              kills[fid] = fibers[fid].kill(killError, function(result) {
                return function() {
                  delete kills[fid];
                  killCount--;
                  if (util.isLeft(result) && util.fromLeft(result)) {
                    setTimeout(function() {
                      throw util.fromLeft(result);
                    }, 0);
                  }
                  if (killCount === 0) {
                    cb();
                  }
                };
              })();
            }
            for (var k in fibers) {
              if (fibers.hasOwnProperty(k)) {
                killCount++;
                kill(k);
              }
            }
            fibers = {};
            fiberId = 0;
            count = 0;
            return function(error3) {
              return new Aff2(SYNC, function() {
                for (var k2 in kills) {
                  if (kills.hasOwnProperty(k2)) {
                    kills[k2]();
                  }
                }
              });
            };
          };
        }
      };
    }
    var SUSPENDED = 0;
    var CONTINUE = 1;
    var STEP_BIND = 2;
    var STEP_RESULT = 3;
    var PENDING = 4;
    var RETURN = 5;
    var COMPLETED = 6;
    function Fiber(util, supervisor, aff) {
      var runTick = 0;
      var status2 = SUSPENDED;
      var step2 = aff;
      var fail3 = null;
      var interrupt = null;
      var bhead = null;
      var btail = null;
      var attempts = null;
      var bracketCount = 0;
      var joinId = 0;
      var joins = null;
      var rethrow = true;
      function run3(localRunTick) {
        var tmp, result, attempt;
        while (true) {
          tmp = null;
          result = null;
          attempt = null;
          switch (status2) {
            case STEP_BIND:
              status2 = CONTINUE;
              try {
                step2 = bhead(step2);
                if (btail === null) {
                  bhead = null;
                } else {
                  bhead = btail._1;
                  btail = btail._2;
                }
              } catch (e) {
                status2 = RETURN;
                fail3 = util.left(e);
                step2 = null;
              }
              break;
            case STEP_RESULT:
              if (util.isLeft(step2)) {
                status2 = RETURN;
                fail3 = step2;
                step2 = null;
              } else if (bhead === null) {
                status2 = RETURN;
              } else {
                status2 = STEP_BIND;
                step2 = util.fromRight(step2);
              }
              break;
            case CONTINUE:
              switch (step2.tag) {
                case BIND:
                  if (bhead) {
                    btail = new Aff2(CONS, bhead, btail);
                  }
                  bhead = step2._2;
                  status2 = CONTINUE;
                  step2 = step2._1;
                  break;
                case PURE:
                  if (bhead === null) {
                    status2 = RETURN;
                    step2 = util.right(step2._1);
                  } else {
                    status2 = STEP_BIND;
                    step2 = step2._1;
                  }
                  break;
                case SYNC:
                  status2 = STEP_RESULT;
                  step2 = runSync(util.left, util.right, step2._1);
                  break;
                case ASYNC:
                  status2 = PENDING;
                  step2 = runAsync(util.left, step2._1, function(result2) {
                    return function() {
                      if (runTick !== localRunTick) {
                        return;
                      }
                      runTick++;
                      Scheduler.enqueue(function() {
                        if (runTick !== localRunTick + 1) {
                          return;
                        }
                        status2 = STEP_RESULT;
                        step2 = result2;
                        run3(runTick);
                      });
                    };
                  });
                  return;
                case THROW:
                  status2 = RETURN;
                  fail3 = util.left(step2._1);
                  step2 = null;
                  break;
                // Enqueue the Catch so that we can call the error handler later on
                // in case of an exception.
                case CATCH:
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step2, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step2, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status2 = CONTINUE;
                  step2 = step2._1;
                  break;
                // Enqueue the Bracket so that we can call the appropriate handlers
                // after resource acquisition.
                case BRACKET:
                  bracketCount++;
                  if (bhead === null) {
                    attempts = new Aff2(CONS, step2, attempts, interrupt);
                  } else {
                    attempts = new Aff2(CONS, step2, new Aff2(CONS, new Aff2(RESUME, bhead, btail), attempts, interrupt), interrupt);
                  }
                  bhead = null;
                  btail = null;
                  status2 = CONTINUE;
                  step2 = step2._1;
                  break;
                case FORK:
                  status2 = STEP_RESULT;
                  tmp = Fiber(util, supervisor, step2._2);
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
                  if (step2._1) {
                    tmp.run();
                  }
                  step2 = util.right(tmp);
                  break;
                case SEQ:
                  status2 = CONTINUE;
                  step2 = sequential2(util, supervisor, step2._1);
                  break;
              }
              break;
            case RETURN:
              bhead = null;
              btail = null;
              if (attempts === null) {
                status2 = COMPLETED;
                step2 = interrupt || fail3 || step2;
              } else {
                tmp = attempts._3;
                attempt = attempts._1;
                attempts = attempts._2;
                switch (attempt.tag) {
                  // We cannot recover from an unmasked interrupt. Otherwise we should
                  // continue stepping, or run the exception handler if an exception
                  // was raised.
                  case CATCH:
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      status2 = RETURN;
                    } else if (fail3) {
                      status2 = CONTINUE;
                      step2 = attempt._2(util.fromLeft(fail3));
                      fail3 = null;
                    }
                    break;
                  // We cannot resume from an unmasked interrupt or exception.
                  case RESUME:
                    if (interrupt && interrupt !== tmp && bracketCount === 0 || fail3) {
                      status2 = RETURN;
                    } else {
                      bhead = attempt._1;
                      btail = attempt._2;
                      status2 = STEP_BIND;
                      step2 = util.fromRight(step2);
                    }
                    break;
                  // If we have a bracket, we should enqueue the handlers,
                  // and continue with the success branch only if the fiber has
                  // not been interrupted. If the bracket acquisition failed, we
                  // should not run either.
                  case BRACKET:
                    bracketCount--;
                    if (fail3 === null) {
                      result = util.fromRight(step2);
                      attempts = new Aff2(CONS, new Aff2(RELEASE, attempt._2, result), attempts, tmp);
                      if (interrupt === tmp || bracketCount > 0) {
                        status2 = CONTINUE;
                        step2 = attempt._3(result);
                      }
                    }
                    break;
                  // Enqueue the appropriate handler. We increase the bracket count
                  // because it should not be cancelled.
                  case RELEASE:
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail3), attempts, interrupt);
                    status2 = CONTINUE;
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      step2 = attempt._1.killed(util.fromLeft(interrupt))(attempt._2);
                    } else if (fail3) {
                      step2 = attempt._1.failed(util.fromLeft(fail3))(attempt._2);
                    } else {
                      step2 = attempt._1.completed(util.fromRight(step2))(attempt._2);
                    }
                    fail3 = null;
                    bracketCount++;
                    break;
                  case FINALIZER:
                    bracketCount++;
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail3), attempts, interrupt);
                    status2 = CONTINUE;
                    step2 = attempt._1;
                    break;
                  case FINALIZED:
                    bracketCount--;
                    status2 = RETURN;
                    step2 = attempt._1;
                    fail3 = attempt._2;
                    break;
                }
              }
              break;
            case COMPLETED:
              for (var k in joins) {
                if (joins.hasOwnProperty(k)) {
                  rethrow = rethrow && joins[k].rethrow;
                  runEff(joins[k].handler(step2));
                }
              }
              joins = null;
              if (interrupt && fail3) {
                setTimeout(function() {
                  throw util.fromLeft(fail3);
                }, 0);
              } else if (util.isLeft(step2) && rethrow) {
                setTimeout(function() {
                  if (rethrow) {
                    throw util.fromLeft(step2);
                  }
                }, 0);
              }
              return;
            case SUSPENDED:
              status2 = CONTINUE;
              break;
            case PENDING:
              return;
          }
        }
      }
      function onComplete(join4) {
        return function() {
          if (status2 === COMPLETED) {
            rethrow = rethrow && join4.rethrow;
            join4.handler(step2)();
            return function() {
            };
          }
          var jid = joinId++;
          joins = joins || {};
          joins[jid] = join4;
          return function() {
            if (joins !== null) {
              delete joins[jid];
            }
          };
        };
      }
      function kill(error3, cb) {
        return function() {
          if (status2 === COMPLETED) {
            cb(util.right(void 0))();
            return function() {
            };
          }
          var canceler = onComplete({
            rethrow: false,
            handler: function() {
              return cb(util.right(void 0));
            }
          })();
          switch (status2) {
            case SUSPENDED:
              interrupt = util.left(error3);
              status2 = COMPLETED;
              step2 = interrupt;
              run3(runTick);
              break;
            case PENDING:
              if (interrupt === null) {
                interrupt = util.left(error3);
              }
              if (bracketCount === 0) {
                if (status2 === PENDING) {
                  attempts = new Aff2(CONS, new Aff2(FINALIZER, step2(error3)), attempts, interrupt);
                }
                status2 = RETURN;
                step2 = null;
                fail3 = null;
                run3(++runTick);
              }
              break;
            default:
              if (interrupt === null) {
                interrupt = util.left(error3);
              }
              if (bracketCount === 0) {
                status2 = RETURN;
                step2 = null;
                fail3 = null;
              }
          }
          return canceler;
        };
      }
      function join3(cb) {
        return function() {
          var canceler = onComplete({
            rethrow: false,
            handler: cb
          })();
          if (status2 === SUSPENDED) {
            run3(runTick);
          }
          return canceler;
        };
      }
      return {
        kill,
        join: join3,
        onComplete,
        isSuspended: function() {
          return status2 === SUSPENDED;
        },
        run: function() {
          if (status2 === SUSPENDED) {
            if (!Scheduler.isDraining()) {
              Scheduler.enqueue(function() {
                run3(runTick);
              });
            } else {
              run3(runTick);
            }
          }
        }
      };
    }
    function runPar(util, supervisor, par, cb) {
      var fiberId = 0;
      var fibers = {};
      var killId = 0;
      var kills = {};
      var early = new Error("[ParAff] Early exit");
      var interrupt = null;
      var root = EMPTY;
      function kill(error3, par2, cb2) {
        var step2 = par2;
        var head3 = null;
        var tail3 = null;
        var count = 0;
        var kills2 = {};
        var tmp, kid;
        loop: while (true) {
          tmp = null;
          switch (step2.tag) {
            case FORKED:
              if (step2._3 === EMPTY) {
                tmp = fibers[step2._1];
                kills2[count++] = tmp.kill(error3, function(result) {
                  return function() {
                    count--;
                    if (count === 0) {
                      cb2(result)();
                    }
                  };
                });
              }
              if (head3 === null) {
                break loop;
              }
              step2 = head3._2;
              if (tail3 === null) {
                head3 = null;
              } else {
                head3 = tail3._1;
                tail3 = tail3._2;
              }
              break;
            case MAP:
              step2 = step2._2;
              break;
            case APPLY:
            case ALT:
              if (head3) {
                tail3 = new Aff2(CONS, head3, tail3);
              }
              head3 = step2;
              step2 = step2._1;
              break;
          }
        }
        if (count === 0) {
          cb2(util.right(void 0))();
        } else {
          kid = 0;
          tmp = count;
          for (; kid < tmp; kid++) {
            kills2[kid] = kills2[kid]();
          }
        }
        return kills2;
      }
      function join3(result, head3, tail3) {
        var fail3, step2, lhs, rhs, tmp, kid;
        if (util.isLeft(result)) {
          fail3 = result;
          step2 = null;
        } else {
          step2 = result;
          fail3 = null;
        }
        loop: while (true) {
          lhs = null;
          rhs = null;
          tmp = null;
          kid = null;
          if (interrupt !== null) {
            return;
          }
          if (head3 === null) {
            cb(fail3 || step2)();
            return;
          }
          if (head3._3 !== EMPTY) {
            return;
          }
          switch (head3.tag) {
            case MAP:
              if (fail3 === null) {
                head3._3 = util.right(head3._1(util.fromRight(step2)));
                step2 = head3._3;
              } else {
                head3._3 = fail3;
              }
              break;
            case APPLY:
              lhs = head3._1._3;
              rhs = head3._2._3;
              if (fail3) {
                head3._3 = fail3;
                tmp = true;
                kid = killId++;
                kills[kid] = kill(early, fail3 === lhs ? head3._2 : head3._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail3 === null) {
                      join3(fail3, null, null);
                    } else {
                      join3(fail3, tail3._1, tail3._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              } else if (lhs === EMPTY || rhs === EMPTY) {
                return;
              } else {
                step2 = util.right(util.fromRight(lhs)(util.fromRight(rhs)));
                head3._3 = step2;
              }
              break;
            case ALT:
              lhs = head3._1._3;
              rhs = head3._2._3;
              if (lhs === EMPTY && util.isLeft(rhs) || rhs === EMPTY && util.isLeft(lhs)) {
                return;
              }
              if (lhs !== EMPTY && util.isLeft(lhs) && rhs !== EMPTY && util.isLeft(rhs)) {
                fail3 = step2 === lhs ? rhs : lhs;
                step2 = null;
                head3._3 = fail3;
              } else {
                head3._3 = step2;
                tmp = true;
                kid = killId++;
                kills[kid] = kill(early, step2 === lhs ? head3._2 : head3._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail3 === null) {
                      join3(step2, null, null);
                    } else {
                      join3(step2, tail3._1, tail3._2);
                    }
                  };
                });
                if (tmp) {
                  tmp = false;
                  return;
                }
              }
              break;
          }
          if (tail3 === null) {
            head3 = null;
          } else {
            head3 = tail3._1;
            tail3 = tail3._2;
          }
        }
      }
      function resolve5(fiber) {
        return function(result) {
          return function() {
            delete fibers[fiber._1];
            fiber._3 = result;
            join3(result, fiber._2._1, fiber._2._2);
          };
        };
      }
      function run3() {
        var status2 = CONTINUE;
        var step2 = par;
        var head3 = null;
        var tail3 = null;
        var tmp, fid;
        loop: while (true) {
          tmp = null;
          fid = null;
          switch (status2) {
            case CONTINUE:
              switch (step2.tag) {
                case MAP:
                  if (head3) {
                    tail3 = new Aff2(CONS, head3, tail3);
                  }
                  head3 = new Aff2(MAP, step2._1, EMPTY, EMPTY);
                  step2 = step2._2;
                  break;
                case APPLY:
                  if (head3) {
                    tail3 = new Aff2(CONS, head3, tail3);
                  }
                  head3 = new Aff2(APPLY, EMPTY, step2._2, EMPTY);
                  step2 = step2._1;
                  break;
                case ALT:
                  if (head3) {
                    tail3 = new Aff2(CONS, head3, tail3);
                  }
                  head3 = new Aff2(ALT, EMPTY, step2._2, EMPTY);
                  step2 = step2._1;
                  break;
                default:
                  fid = fiberId++;
                  status2 = RETURN;
                  tmp = step2;
                  step2 = new Aff2(FORKED, fid, new Aff2(CONS, head3, tail3), EMPTY);
                  tmp = Fiber(util, supervisor, tmp);
                  tmp.onComplete({
                    rethrow: false,
                    handler: resolve5(step2)
                  })();
                  fibers[fid] = tmp;
                  if (supervisor) {
                    supervisor.register(tmp);
                  }
              }
              break;
            case RETURN:
              if (head3 === null) {
                break loop;
              }
              if (head3._1 === EMPTY) {
                head3._1 = step2;
                status2 = CONTINUE;
                step2 = head3._2;
                head3._2 = EMPTY;
              } else {
                head3._2 = step2;
                step2 = head3;
                if (tail3 === null) {
                  head3 = null;
                } else {
                  head3 = tail3._1;
                  tail3 = tail3._2;
                }
              }
          }
        }
        root = step2;
        for (fid = 0; fid < fiberId; fid++) {
          fibers[fid].run();
        }
      }
      function cancel(error3, cb2) {
        interrupt = util.left(error3);
        var innerKills;
        for (var kid in kills) {
          if (kills.hasOwnProperty(kid)) {
            innerKills = kills[kid];
            for (kid in innerKills) {
              if (innerKills.hasOwnProperty(kid)) {
                innerKills[kid]();
              }
            }
          }
        }
        kills = null;
        var newKills = kill(error3, root, cb2);
        return function(killError) {
          return new Aff2(ASYNC, function(killCb) {
            return function() {
              for (var kid2 in newKills) {
                if (newKills.hasOwnProperty(kid2)) {
                  newKills[kid2]();
                }
              }
              return nonCanceler2;
            };
          });
        };
      }
      run3();
      return function(killError) {
        return new Aff2(ASYNC, function(killCb) {
          return function() {
            return cancel(killError, killCb);
          };
        });
      };
    }
    function sequential2(util, supervisor, par) {
      return new Aff2(ASYNC, function(cb) {
        return function() {
          return runPar(util, supervisor, par, cb);
        };
      });
    }
    Aff2.EMPTY = EMPTY;
    Aff2.Pure = AffCtr(PURE);
    Aff2.Throw = AffCtr(THROW);
    Aff2.Catch = AffCtr(CATCH);
    Aff2.Sync = AffCtr(SYNC);
    Aff2.Async = AffCtr(ASYNC);
    Aff2.Bind = AffCtr(BIND);
    Aff2.Bracket = AffCtr(BRACKET);
    Aff2.Fork = AffCtr(FORK);
    Aff2.Seq = AffCtr(SEQ);
    Aff2.ParMap = AffCtr(MAP);
    Aff2.ParApply = AffCtr(APPLY);
    Aff2.ParAlt = AffCtr(ALT);
    Aff2.Fiber = Fiber;
    Aff2.Supervisor = Supervisor;
    Aff2.Scheduler = Scheduler;
    Aff2.nonCanceler = nonCanceler2;
    return Aff2;
  }();
  var _pure = Aff.Pure;
  var _throwError = Aff.Throw;
  function _catchError(aff) {
    return function(k) {
      return Aff.Catch(aff, k);
    };
  }
  function _map(f) {
    return function(aff) {
      if (aff.tag === Aff.Pure.tag) {
        return Aff.Pure(f(aff._1));
      } else {
        return Aff.Bind(aff, function(value12) {
          return Aff.Pure(f(value12));
        });
      }
    };
  }
  function _bind(aff) {
    return function(k) {
      return Aff.Bind(aff, k);
    };
  }
  var _liftEffect = Aff.Sync;
  function _parAffMap(f) {
    return function(aff) {
      return Aff.ParMap(f, aff);
    };
  }
  function _parAffApply(aff1) {
    return function(aff2) {
      return Aff.ParApply(aff1, aff2);
    };
  }
  var makeAff = Aff.Async;
  function generalBracket(acquire) {
    return function(options2) {
      return function(k) {
        return Aff.Bracket(acquire, options2, k);
      };
    };
  }
  function _makeFiber(util, aff) {
    return function() {
      return Aff.Fiber(util, null, aff);
    };
  }
  var _delay = /* @__PURE__ */ function() {
    function setDelay(n, k) {
      if (n === 0 && typeof setImmediate !== "undefined") {
        return setImmediate(k);
      } else {
        return setTimeout(k, n);
      }
    }
    function clearDelay(n, t) {
      if (n === 0 && typeof clearImmediate !== "undefined") {
        return clearImmediate(t);
      } else {
        return clearTimeout(t);
      }
    }
    return function(right, ms) {
      return Aff.Async(function(cb) {
        return function() {
          var timer = setDelay(ms, cb(right()));
          return function() {
            return Aff.Sync(function() {
              return right(clearDelay(ms, timer));
            });
          };
        };
      });
    };
  }();
  var _sequential = Aff.Seq;

  // output/Control.Monad.Rec.Class/index.js
  var Loop = /* @__PURE__ */ function() {
    function Loop2(value0) {
      this.value0 = value0;
    }
    ;
    Loop2.create = function(value0) {
      return new Loop2(value0);
    };
    return Loop2;
  }();
  var Done = /* @__PURE__ */ function() {
    function Done2(value0) {
      this.value0 = value0;
    }
    ;
    Done2.create = function(value0) {
      return new Done2(value0);
    };
    return Done2;
  }();
  var tailRecM = function(dict) {
    return dict.tailRecM;
  };

  // output/Control.Monad.ST.Internal/foreign.js
  var map_ = function(f) {
    return function(a) {
      return function() {
        return f(a());
      };
    };
  };
  var pure_ = function(a) {
    return function() {
      return a;
    };
  };
  var bind_ = function(a) {
    return function(f) {
      return function() {
        return f(a())();
      };
    };
  };
  function newSTRef(val) {
    return function() {
      return { value: val };
    };
  }
  var read2 = function(ref) {
    return function() {
      return ref.value;
    };
  };
  var modifyImpl2 = function(f) {
    return function(ref) {
      return function() {
        var t = f(ref.value);
        ref.value = t.state;
        return t.value;
      };
    };
  };
  var write2 = function(a) {
    return function(ref) {
      return function() {
        return ref.value = a;
      };
    };
  };

  // output/Control.Monad.ST.Internal/index.js
  var $runtime_lazy3 = function(name15, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name15 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var modify$prime = modifyImpl2;
  var modify = function(f) {
    return modify$prime(function(s) {
      var s$prime = f(s);
      return {
        state: s$prime,
        value: s$prime
      };
    });
  };
  var functorST = {
    map: map_
  };
  var monadST = {
    Applicative0: function() {
      return applicativeST;
    },
    Bind1: function() {
      return bindST;
    }
  };
  var bindST = {
    bind: bind_,
    Apply0: function() {
      return $lazy_applyST(0);
    }
  };
  var applicativeST = {
    pure: pure_,
    Apply0: function() {
      return $lazy_applyST(0);
    }
  };
  var $lazy_applyST = /* @__PURE__ */ $runtime_lazy3("applyST", "Control.Monad.ST.Internal", function() {
    return {
      apply: ap(monadST),
      Functor0: function() {
        return functorST;
      }
    };
  });
  var applyST = /* @__PURE__ */ $lazy_applyST(47);

  // output/Control.Monad.Trans.Class/index.js
  var lift = function(dict) {
    return dict.lift;
  };

  // output/Effect.Class/index.js
  var liftEffect = function(dict) {
    return dict.liftEffect;
  };

  // output/Control.Monad.Except.Trans/index.js
  var map7 = /* @__PURE__ */ map(functorEither);
  var ExceptT = function(x) {
    return x;
  };
  var withExceptT = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return function(f) {
      return function(v) {
        var mapLeft = function(v1) {
          return function(v2) {
            if (v2 instanceof Right) {
              return new Right(v2.value0);
            }
            ;
            if (v2 instanceof Left) {
              return new Left(v1(v2.value0));
            }
            ;
            throw new Error("Failed pattern match at Control.Monad.Except.Trans (line 43, column 3 - line 43, column 32): " + [v1.constructor.name, v2.constructor.name]);
          };
        };
        return map111(mapLeft(f))(v);
      };
    };
  };
  var runExceptT = function(v) {
    return v;
  };
  var mapExceptT = function(f) {
    return function(v) {
      return f(v);
    };
  };
  var functorExceptT = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return {
      map: function(f) {
        return mapExceptT(map111(map7(f)));
      }
    };
  };
  var except = function(dictApplicative) {
    var $191 = pure(dictApplicative);
    return function($192) {
      return ExceptT($191($192));
    };
  };
  var monadExceptT = function(dictMonad) {
    return {
      Applicative0: function() {
        return applicativeExceptT(dictMonad);
      },
      Bind1: function() {
        return bindExceptT(dictMonad);
      }
    };
  };
  var bindExceptT = function(dictMonad) {
    var bind20 = bind(dictMonad.Bind1());
    var pure24 = pure(dictMonad.Applicative0());
    return {
      bind: function(v) {
        return function(k) {
          return bind20(v)(either(function($193) {
            return pure24(Left.create($193));
          })(function(a) {
            var v1 = k(a);
            return v1;
          }));
        };
      },
      Apply0: function() {
        return applyExceptT(dictMonad);
      }
    };
  };
  var applyExceptT = function(dictMonad) {
    var functorExceptT1 = functorExceptT(dictMonad.Bind1().Apply0().Functor0());
    return {
      apply: ap(monadExceptT(dictMonad)),
      Functor0: function() {
        return functorExceptT1;
      }
    };
  };
  var applicativeExceptT = function(dictMonad) {
    return {
      pure: function() {
        var $194 = pure(dictMonad.Applicative0());
        return function($195) {
          return ExceptT($194(Right.create($195)));
        };
      }(),
      Apply0: function() {
        return applyExceptT(dictMonad);
      }
    };
  };
  var monadThrowExceptT = function(dictMonad) {
    var monadExceptT1 = monadExceptT(dictMonad);
    return {
      throwError: function() {
        var $204 = pure(dictMonad.Applicative0());
        return function($205) {
          return ExceptT($204(Left.create($205)));
        };
      }(),
      Monad0: function() {
        return monadExceptT1;
      }
    };
  };

  // output/Control.Monad.Maybe.Trans/index.js
  var map8 = /* @__PURE__ */ map(functorMaybe);
  var MaybeT = function(x) {
    return x;
  };
  var runMaybeT = function(v) {
    return v;
  };
  var monadTransMaybeT = {
    lift: function(dictMonad) {
      var $163 = liftM1(dictMonad)(Just.create);
      return function($164) {
        return MaybeT($163($164));
      };
    }
  };
  var functorMaybeT = function(dictFunctor) {
    var map111 = map(dictFunctor);
    return {
      map: function(f) {
        return function(v) {
          return map111(map8(f))(v);
        };
      }
    };
  };
  var monadMaybeT = function(dictMonad) {
    return {
      Applicative0: function() {
        return applicativeMaybeT(dictMonad);
      },
      Bind1: function() {
        return bindMaybeT(dictMonad);
      }
    };
  };
  var bindMaybeT = function(dictMonad) {
    var bind20 = bind(dictMonad.Bind1());
    var pure24 = pure(dictMonad.Applicative0());
    return {
      bind: function(v) {
        return function(f) {
          return bind20(v)(function(v1) {
            if (v1 instanceof Nothing) {
              return pure24(Nothing.value);
            }
            ;
            if (v1 instanceof Just) {
              var v2 = f(v1.value0);
              return v2;
            }
            ;
            throw new Error("Failed pattern match at Control.Monad.Maybe.Trans (line 55, column 11 - line 57, column 42): " + [v1.constructor.name]);
          });
        };
      },
      Apply0: function() {
        return applyMaybeT(dictMonad);
      }
    };
  };
  var applyMaybeT = function(dictMonad) {
    var functorMaybeT1 = functorMaybeT(dictMonad.Bind1().Apply0().Functor0());
    return {
      apply: ap(monadMaybeT(dictMonad)),
      Functor0: function() {
        return functorMaybeT1;
      }
    };
  };
  var applicativeMaybeT = function(dictMonad) {
    return {
      pure: function() {
        var $165 = pure(dictMonad.Applicative0());
        return function($166) {
          return MaybeT($165(Just.create($166)));
        };
      }(),
      Apply0: function() {
        return applyMaybeT(dictMonad);
      }
    };
  };

  // output/Control.Parallel.Class/index.js
  var sequential = function(dict) {
    return dict.sequential;
  };
  var parallel = function(dict) {
    return dict.parallel;
  };

  // output/Control.Parallel/index.js
  var identity7 = /* @__PURE__ */ identity(categoryFn);
  var parTraverse_ = function(dictParallel) {
    var sequential2 = sequential(dictParallel);
    var parallel3 = parallel(dictParallel);
    return function(dictApplicative) {
      var traverse_3 = traverse_(dictApplicative);
      return function(dictFoldable) {
        var traverse_1 = traverse_3(dictFoldable);
        return function(f) {
          var $51 = traverse_1(function($53) {
            return parallel3(f($53));
          });
          return function($52) {
            return sequential2($51($52));
          };
        };
      };
    };
  };
  var parSequence_ = function(dictParallel) {
    var parTraverse_1 = parTraverse_(dictParallel);
    return function(dictApplicative) {
      var parTraverse_2 = parTraverse_1(dictApplicative);
      return function(dictFoldable) {
        return parTraverse_2(dictFoldable)(identity7);
      };
    };
  };

  // output/Effect.Unsafe/foreign.js
  var unsafePerformEffect = function(f) {
    return f();
  };

  // output/Partial.Unsafe/foreign.js
  var _unsafePartial = function(f) {
    return f();
  };

  // output/Partial/foreign.js
  var _crashWith = function(msg) {
    throw new Error(msg);
  };

  // output/Partial/index.js
  var crashWith = function() {
    return _crashWith;
  };

  // output/Partial.Unsafe/index.js
  var crashWith2 = /* @__PURE__ */ crashWith();
  var unsafePartial = _unsafePartial;
  var unsafeCrashWith = function(msg) {
    return unsafePartial(function() {
      return crashWith2(msg);
    });
  };

  // output/Effect.Aff/index.js
  var $runtime_lazy4 = function(name15, moduleName, init3) {
    var state3 = 0;
    var val;
    return function(lineNumber) {
      if (state3 === 2) return val;
      if (state3 === 1) throw new ReferenceError(name15 + " was needed before it finished initializing (module " + moduleName + ", line " + lineNumber + ")", moduleName, lineNumber);
      state3 = 1;
      val = init3();
      state3 = 2;
      return val;
    };
  };
  var $$void2 = /* @__PURE__ */ $$void(functorEffect);
  var Canceler = function(x) {
    return x;
  };
  var functorParAff = {
    map: _parAffMap
  };
  var functorAff = {
    map: _map
  };
  var ffiUtil = /* @__PURE__ */ function() {
    var unsafeFromRight = function(v) {
      if (v instanceof Right) {
        return v.value0;
      }
      ;
      if (v instanceof Left) {
        return unsafeCrashWith("unsafeFromRight: Left");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 412, column 21 - line 414, column 54): " + [v.constructor.name]);
    };
    var unsafeFromLeft = function(v) {
      if (v instanceof Left) {
        return v.value0;
      }
      ;
      if (v instanceof Right) {
        return unsafeCrashWith("unsafeFromLeft: Right");
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 407, column 20 - line 409, column 55): " + [v.constructor.name]);
    };
    var isLeft = function(v) {
      if (v instanceof Left) {
        return true;
      }
      ;
      if (v instanceof Right) {
        return false;
      }
      ;
      throw new Error("Failed pattern match at Effect.Aff (line 402, column 12 - line 404, column 21): " + [v.constructor.name]);
    };
    return {
      isLeft,
      fromLeft: unsafeFromLeft,
      fromRight: unsafeFromRight,
      left: Left.create,
      right: Right.create
    };
  }();
  var makeFiber = function(aff) {
    return _makeFiber(ffiUtil, aff);
  };
  var launchAff = function(aff) {
    return function __do5() {
      var fiber = makeFiber(aff)();
      fiber.run();
      return fiber;
    };
  };
  var launchAff_ = function($75) {
    return $$void2(launchAff($75));
  };
  var delay = function(v) {
    return _delay(Right.create, v);
  };
  var bracket = function(acquire) {
    return function(completed) {
      return generalBracket(acquire)({
        killed: $$const(completed),
        failed: $$const(completed),
        completed: $$const(completed)
      });
    };
  };
  var applyParAff = {
    apply: _parAffApply,
    Functor0: function() {
      return functorParAff;
    }
  };
  var monadAff = {
    Applicative0: function() {
      return applicativeAff;
    },
    Bind1: function() {
      return bindAff;
    }
  };
  var bindAff = {
    bind: _bind,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var applicativeAff = {
    pure: _pure,
    Apply0: function() {
      return $lazy_applyAff(0);
    }
  };
  var $lazy_applyAff = /* @__PURE__ */ $runtime_lazy4("applyAff", "Effect.Aff", function() {
    return {
      apply: ap(monadAff),
      Functor0: function() {
        return functorAff;
      }
    };
  });
  var applyAff = /* @__PURE__ */ $lazy_applyAff(73);
  var pure22 = /* @__PURE__ */ pure(applicativeAff);
  var bind12 = /* @__PURE__ */ bind(bindAff);
  var bindFlipped2 = /* @__PURE__ */ bindFlipped(bindAff);
  var $$finally = function(fin) {
    return function(a) {
      return bracket(pure22(unit))($$const(fin))($$const(a));
    };
  };
  var parallelAff = {
    parallel: unsafeCoerce2,
    sequential: _sequential,
    Apply0: function() {
      return applyAff;
    },
    Apply1: function() {
      return applyParAff;
    }
  };
  var parallel2 = /* @__PURE__ */ parallel(parallelAff);
  var applicativeParAff = {
    pure: function($76) {
      return parallel2(pure22($76));
    },
    Apply0: function() {
      return applyParAff;
    }
  };
  var parSequence_2 = /* @__PURE__ */ parSequence_(parallelAff)(applicativeParAff)(foldableArray);
  var semigroupCanceler = {
    append: function(v) {
      return function(v1) {
        return function(err) {
          return parSequence_2([v(err), v1(err)]);
        };
      };
    }
  };
  var monadEffectAff = {
    liftEffect: _liftEffect,
    Monad0: function() {
      return monadAff;
    }
  };
  var liftEffect2 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var effectCanceler = function($77) {
    return Canceler($$const(liftEffect2($77)));
  };
  var monadThrowAff = {
    throwError: _throwError,
    Monad0: function() {
      return monadAff;
    }
  };
  var monadErrorAff = {
    catchError: _catchError,
    MonadThrow0: function() {
      return monadThrowAff;
    }
  };
  var $$try3 = /* @__PURE__ */ $$try2(monadErrorAff);
  var runAff = function(k) {
    return function(aff) {
      return launchAff(bindFlipped2(function($83) {
        return liftEffect2(k($83));
      })($$try3(aff)));
    };
  };
  var runAff_ = function(k) {
    return function(aff) {
      return $$void2(runAff(k)(aff));
    };
  };
  var monadRecAff = {
    tailRecM: function(k) {
      var go2 = function(a) {
        return bind12(k(a))(function(res) {
          if (res instanceof Done) {
            return pure22(res.value0);
          }
          ;
          if (res instanceof Loop) {
            return go2(res.value0);
          }
          ;
          throw new Error("Failed pattern match at Effect.Aff (line 104, column 7 - line 106, column 23): " + [res.constructor.name]);
        });
      };
      return go2;
    },
    Monad0: function() {
      return monadAff;
    }
  };
  var nonCanceler = /* @__PURE__ */ $$const(/* @__PURE__ */ pure22(unit));
  var monoidCanceler = {
    mempty: nonCanceler,
    Semigroup0: function() {
      return semigroupCanceler;
    }
  };

  // output/Effect.Console/foreign.js
  var log = function(s) {
    return function() {
      console.log(s);
    };
  };

  // output/Components.Modal/foreign.js
  function showModal(id2) {
    return function() {
      const el = document.getElementById(id2);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.show();
      setTimeout(() => {
        modal.hide(id2);
      }, 1e4);
    };
  }
  function hideModal(id2) {
    return function() {
      const el = document.getElementById(id2);
      const modal = bootstrap.Modal.getOrCreateInstance(el);
      modal.hide();
    };
  }

  // output/Effect.Timer/foreign.js
  function setTimeoutImpl(ms) {
    return function(fn) {
      return function() {
        return setTimeout(fn, ms);
      };
    };
  }
  function setIntervalImpl(ms) {
    return function(fn) {
      return function() {
        return setInterval(fn, ms);
      };
    };
  }

  // output/Effect.Timer/index.js
  var setTimeout2 = setTimeoutImpl;
  var setInterval2 = setIntervalImpl;

  // output/Web.DOM.Document/foreign.js
  var getEffProp = function(name15) {
    return function(doc) {
      return function() {
        return doc[name15];
      };
    };
  };
  var url = getEffProp("URL");
  var documentURI = getEffProp("documentURI");
  var origin2 = getEffProp("origin");
  var _compatMode = getEffProp("compatMode");
  var characterSet = getEffProp("characterSet");
  var contentType = getEffProp("contentType");
  var _documentElement2 = getEffProp("documentElement");
  function createElement(localName2) {
    return function(doc) {
      return function() {
        return doc.createElement(localName2);
      };
    };
  }

  // output/Web.DOM.Element/foreign.js
  var getProp = function(name15) {
    return function(doctype) {
      return doctype[name15];
    };
  };
  var _namespaceURI = getProp("namespaceURI");
  var _prefix = getProp("prefix");
  var localName = getProp("localName");
  var tagName = getProp("tagName");
  function classList(element) {
    return function() {
      return element.classList;
    };
  }

  // output/Web.DOM.ParentNode/foreign.js
  var getEffProp2 = function(name15) {
    return function(node) {
      return function() {
        return node[name15];
      };
    };
  };
  var children = getEffProp2("children");
  var _firstElementChild = getEffProp2("firstElementChild");
  var _lastElementChild = getEffProp2("lastElementChild");
  var childElementCount = getEffProp2("childElementCount");
  function _querySelector(selector) {
    return function(node) {
      return function() {
        return node.querySelector(selector);
      };
    };
  }

  // output/Web.DOM.ParentNode/index.js
  var map9 = /* @__PURE__ */ map(functorEffect);
  var querySelector = function(qs) {
    var $2 = map9(toMaybe);
    var $3 = _querySelector(qs);
    return function($4) {
      return $2($3($4));
    };
  };
  var firstElementChild = /* @__PURE__ */ function() {
    var $7 = map9(toMaybe);
    return function($8) {
      return $7(_firstElementChild($8));
    };
  }();

  // output/Web.DOM.Element/index.js
  var toParentNode = unsafeCoerce2;
  var toNode5 = unsafeCoerce2;
  var toEventTarget2 = unsafeCoerce2;
  var fromNode = /* @__PURE__ */ unsafeReadProtoTagged("Element");
  var fromEventTarget2 = /* @__PURE__ */ unsafeReadProtoTagged("Element");

  // output/Web.DOM.Node/foreign.js
  var getEffProp3 = function(name15) {
    return function(node) {
      return function() {
        return node[name15];
      };
    };
  };
  var baseURI = getEffProp3("baseURI");
  var _ownerDocument = getEffProp3("ownerDocument");
  var _parentNode = getEffProp3("parentNode");
  var _parentElement = getEffProp3("parentElement");
  var childNodes = getEffProp3("childNodes");
  var _firstChild = getEffProp3("firstChild");
  var _lastChild = getEffProp3("lastChild");
  var _previousSibling = getEffProp3("previousSibling");
  var _nextSibling = getEffProp3("nextSibling");
  var _nodeValue = getEffProp3("nodeValue");
  var textContent = getEffProp3("textContent");
  function setTextContent(value12) {
    return function(node) {
      return function() {
        node.textContent = value12;
      };
    };
  }
  function deepClone(node) {
    return function() {
      return node.cloneNode(true);
    };
  }
  function insertBefore(node1) {
    return function(node2) {
      return function(parent2) {
        return function() {
          parent2.insertBefore(node1, node2);
        };
      };
    };
  }
  function appendChild(node) {
    return function(parent2) {
      return function() {
        parent2.appendChild(node);
      };
    };
  }
  function removeChild(node) {
    return function(parent2) {
      return function() {
        parent2.removeChild(node);
      };
    };
  }

  // output/Web.DOM.Node/index.js
  var map10 = /* @__PURE__ */ map(functorEffect);
  var parentNode = /* @__PURE__ */ function() {
    var $6 = map10(toMaybe);
    return function($7) {
      return $6(_parentNode($7));
    };
  }();

  // output/Handers.ErrorHandlers/index.js
  var pure3 = /* @__PURE__ */ pure(applicativeEffect);
  var traverse2 = /* @__PURE__ */ traverse(traversableArray)(applicativeEffect);
  var $$void3 = /* @__PURE__ */ $$void(functorEffect);
  var catchError3 = /* @__PURE__ */ catchError(monadErrorEffect);
  var applySecond2 = /* @__PURE__ */ applySecond(applyEffect);
  var createErrorList = function(errorMessage) {
    var errorLines = split("<br>")(errorMessage);
    return function __do5() {
      var w = windowImpl();
      var htmlDoc = document2(w)();
      var doc = toDocument(htmlDoc);
      var ulElementRaw = createElement("ul")(doc)();
      var ulElement = function() {
        var v = fromElement15(ulElementRaw);
        if (v instanceof Nothing) {
          return throwMinsiError(new HTMLElementNotFound("ul"))();
        }
        ;
        if (v instanceof Just) {
          return v.value0;
        }
        ;
        throw new Error("Failed pattern match at Handers.ErrorHandlers (line 86, column 16 - line 88, column 21): " + [v.constructor.name]);
      }();
      var ulNode = toNode5(toElement8(ulElement));
      traverse2(function(line) {
        return function __do6() {
          var liElementRaw = createElement("li")(doc)();
          var liElement = function() {
            var v = fromElement10(liElementRaw);
            if (v instanceof Nothing) {
              return throwMinsiError(new HTMLElementNotFound("li"))();
            }
            ;
            if (v instanceof Just) {
              return v.value0;
            }
            ;
            throw new Error("Failed pattern match at Handers.ErrorHandlers (line 93, column 22 - line 95, column 27): " + [v.constructor.name]);
          }();
          var liNode = toNode5(toElement5(liElement));
          setTextContent(line)(liNode)();
          return appendChild(liNode)(ulNode)();
        };
      })(errorLines)();
      return ulElement;
    };
  };
  var showMinsiErrorDialog = function(errorMessage) {
    return function __do5() {
      var doc = getDocument();
      var minsiErrorModalContent = loadDiv(minsiErrorModalContentId)(doc)();
      var errorList = createErrorList(errorMessage)();
      var minsiErrorModalContentNode = toNode(minsiErrorModalContent);
      var errorListNode = toNode5(toElement8(errorList));
      appendChild(errorListNode)(minsiErrorModalContentNode)();
      return showModal(minsiErrorModalId)();
    };
  };
  var writeToMinsiLog = function(errorMessage) {
    return function __do5() {
      var doc = getDocument();
      var minsiLog = loadDiv(minsiLogId)(doc)();
      var errorList = createErrorList(errorMessage)();
      var minsiLogNode = toNode(minsiLog);
      var errorListNode = toNode5(toElement8(errorList));
      appendChild(errorListNode)(minsiLogNode)();
      return $$void3(setTimeout2(5e3)(removeChild(errorListNode)(minsiLogNode)))();
    };
  };
  var genericErrorsHandler = function(p) {
    return catchError3(p)(function(e) {
      var errorMessage = message(e);
      var handleError = function() {
        var $16 = isCriticalError(e);
        if ($16) {
          return showMinsiErrorDialog(errorMessage);
        }
        ;
        return writeToMinsiLog(errorMessage);
      }();
      return applySecond2(log(errorMessage))(catchError3(handleError)($$const(raiseErrorAlert(errorMessage))));
    });
  };
  var genericErrorsHandlerEither = function(v) {
    if (v instanceof Right) {
      return pure3(unit);
    }
    ;
    if (v instanceof Left) {
      var errorMessage = message(v.value0);
      var handleError = function() {
        var $19 = isCriticalError(v.value0);
        if ($19) {
          return showMinsiErrorDialog(errorMessage);
        }
        ;
        return writeToMinsiLog(errorMessage);
      }();
      return applySecond2(log(errorMessage))(catchError3(handleError)($$const(raiseErrorAlert(errorMessage))));
    }
    ;
    throw new Error("Failed pattern match at Handers.ErrorHandlers (line 45, column 1 - line 45, column 70): " + [v.constructor.name]);
  };

  // output/Data.Validation.Semigroup/index.js
  var V = function(x) {
    return x;
  };
  var validation = function(v) {
    return function(v1) {
      return function(v2) {
        if (v2 instanceof Left) {
          return v(v2.value0);
        }
        ;
        if (v2 instanceof Right) {
          return v1(v2.value0);
        }
        ;
        throw new Error("Failed pattern match at Data.Validation.Semigroup (line 48, column 1 - line 48, column 84): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
      };
    };
  };
  var toEither = function(v) {
    return v;
  };
  var invalid = function($100) {
    return V(Left.create($100));
  };
  var functorV = functorEither;
  var foldableV = {
    foldMap: function(dictMonoid) {
      return validation($$const(mempty(dictMonoid)));
    },
    foldr: function(f) {
      return function(b) {
        return validation($$const(b))(flip(f)(b));
      };
    },
    foldl: function(f) {
      return function(b) {
        return validation($$const(b))(f(b));
      };
    }
  };
  var bifunctorV = bifunctorEither;
  var applyV = function(dictSemigroup) {
    var append12 = append(dictSemigroup);
    return {
      apply: function(v) {
        return function(v1) {
          if (v instanceof Left && v1 instanceof Left) {
            return new Left(append12(v.value0)(v1.value0));
          }
          ;
          if (v instanceof Left) {
            return new Left(v.value0);
          }
          ;
          if (v1 instanceof Left) {
            return new Left(v1.value0);
          }
          ;
          if (v instanceof Right && v1 instanceof Right) {
            return new Right(v.value0(v1.value0));
          }
          ;
          throw new Error("Failed pattern match at Data.Validation.Semigroup (line 89, column 1 - line 93, column 54): " + [v.constructor.name, v1.constructor.name]);
        };
      },
      Functor0: function() {
        return functorV;
      }
    };
  };
  var applicativeV = function(dictSemigroup) {
    var applyV1 = applyV(dictSemigroup);
    return {
      pure: function($108) {
        return V(Right.create($108));
      },
      Apply0: function() {
        return applyV1;
      }
    };
  };
  var andThen = function(v1) {
    return function(f) {
      return validation(invalid)(f)(v1);
    };
  };

  // output/Control.Monad.Loops/index.js
  var whileM_ = function(dictMonad) {
    var bind20 = bind(dictMonad.Bind1());
    var pure24 = pure(dictMonad.Applicative0());
    return function(p) {
      return function(f) {
        return bind20(p)(function(v) {
          if (v) {
            return bind20(f)(function(v1) {
              return whileM_(dictMonad)(p)(f);
            });
          }
          ;
          return pure24(unit);
        });
      };
    };
  };
  var iterateUntilM = function(dictMonad) {
    var pure24 = pure(dictMonad.Applicative0());
    var bind20 = bind(dictMonad.Bind1());
    return function(p) {
      return function(f) {
        return function(v) {
          var $181 = p(v);
          if ($181) {
            return pure24(v);
          }
          ;
          return bind20(f(v))(iterateUntilM(dictMonad)(p)(f));
        };
      };
    };
  };

  // output/Data.Int/foreign.js
  var fromNumberImpl = function(just) {
    return function(nothing) {
      return function(n) {
        return (n | 0) === n ? just(n) : nothing;
      };
    };
  };
  var toNumber = function(n) {
    return n;
  };
  var fromStringAsImpl = function(just) {
    return function(nothing) {
      return function(radix) {
        var digits;
        if (radix < 11) {
          digits = "[0-" + (radix - 1).toString() + "]";
        } else if (radix === 11) {
          digits = "[0-9a]";
        } else {
          digits = "[0-9a-" + String.fromCharCode(86 + radix) + "]";
        }
        var pattern2 = new RegExp("^[\\+\\-]?" + digits + "+$", "i");
        return function(s) {
          if (pattern2.test(s)) {
            var i = parseInt(s, radix);
            return (i | 0) === i ? just(i) : nothing;
          } else {
            return nothing;
          }
        };
      };
    };
  };

  // output/Data.Number/foreign.js
  var isFiniteImpl = isFinite;
  var floor = Math.floor;

  // output/Data.Int/index.js
  var top2 = /* @__PURE__ */ top(boundedInt);
  var bottom2 = /* @__PURE__ */ bottom(boundedInt);
  var fromStringAs = /* @__PURE__ */ function() {
    return fromStringAsImpl(Just.create)(Nothing.value);
  }();
  var fromString = /* @__PURE__ */ fromStringAs(10);
  var fromNumber = /* @__PURE__ */ function() {
    return fromNumberImpl(Just.create)(Nothing.value);
  }();
  var unsafeClamp = function(x) {
    if (!isFiniteImpl(x)) {
      return 0;
    }
    ;
    if (x >= toNumber(top2)) {
      return top2;
    }
    ;
    if (x <= toNumber(bottom2)) {
      return bottom2;
    }
    ;
    if (otherwise) {
      return fromMaybe(0)(fromNumber(x));
    }
    ;
    throw new Error("Failed pattern match at Data.Int (line 72, column 1 - line 72, column 29): " + [x.constructor.name]);
  };
  var floor2 = function($39) {
    return unsafeClamp(floor($39));
  };

  // output/Handers.YoutubeVideo.Foreign/foreign.js
  var player;
  var embedVideo = function(embedVideoConfig) {
    return function() {
      if (typeof player !== "undefined" && player !== null) {
        try {
          if (player.getVideoData && typeof player.getVideoData === "function") {
            const videoData = player.getVideoData();
            const currentVideoId = videoData && videoData.video_id;
            if (currentVideoId === embedVideoConfig.videoId) {
              console.log("Video ID is the same, skipping reload");
              return;
            }
          }
        } catch (e) {
          console.log("Could not get current video data, proceeding with load");
        }
        try {
          player.loadVideoById({
            videoId: embedVideoConfig.videoId,
            startSeconds: embedVideoConfig.startTime
            // endSeconds: Number,
          });
          console.log("Video loaded using loadVideoById");
        } catch (error3) {
          console.error("Error loading video:", error3);
          throw error3;
        }
      } else {
        try {
          player = new YT.Player(embedVideoConfig.resultPreviewId, {
            height: embedVideoConfig.height,
            width: embedVideoConfig.width,
            videoId: embedVideoConfig.videoId,
            playerVars: {
              playsinline: 1,
              start: embedVideoConfig.startTime,
              loop: 1
            }
          });
          console.log("Player created successfully");
        } catch (error3) {
          console.error("Error creating YouTube player:", error3);
          throw error3;
        }
      }
    };
  };
  var getPlayerCurrentTime = () => {
    if (typeof player !== "undefined" && player !== null) {
      try {
        if (player.getCurrentTime && typeof player.getCurrentTime === "function") {
          return player.getCurrentTime();
        }
      } catch (e) {
        console.error("Error calling getCurrentTime:", e);
      }
    }
    return 0;
  };
  var getVideoDuration = () => {
    if (typeof player !== "undefined" && player !== null) {
      try {
        if (player.getDuration && typeof player.getDuration === "function") {
          const duration2 = player.getDuration();
          if (duration2 && !isNaN(duration2) && duration2 > 0) {
            return duration2;
          }
        }
      } catch (e) {
        console.error("Error calling getDuration:", e);
      }
    }
    return 100;
  };
  var isPlayerReady = () => {
    if (typeof player === "undefined" || player === null) {
      return false;
    }
    const hasGetDuration = player.getDuration && typeof player.getDuration === "function";
    const hasGetCurrentTime = player.getCurrentTime && typeof player.getCurrentTime === "function";
    let isReady = false;
    if (hasGetDuration) {
      try {
        const duration2 = player.getDuration();
        isReady = duration2 && !isNaN(duration2) && duration2 > 0;
      } catch (e) {
        isReady = false;
      }
    }
    return hasGetDuration && hasGetCurrentTime && isReady;
  };

  // output/Web.Event.EventTarget/foreign.js
  function eventListener(fn) {
    return function() {
      return function(event) {
        return fn(event)();
      };
    };
  }
  function addEventListener(type) {
    return function(listener) {
      return function(useCapture) {
        return function(target6) {
          return function() {
            return target6.addEventListener(type, listener, useCapture);
          };
        };
      };
    };
  }

  // output/Web.HTML.Event.EventTypes/index.js
  var input = "input";
  var click2 = "click";
  var change = "change";

  // output/Handlers.CutRangeHandler/index.js
  var show3 = /* @__PURE__ */ show(showInt);
  var when2 = /* @__PURE__ */ when(applicativeEffect);
  var CRET = /* @__PURE__ */ function() {
    function CRET2(value0) {
      this.value0 = value0;
    }
    ;
    CRET2.create = function(value0) {
      return new CRET2(value0);
    };
    return CRET2;
  }();
  var updateCutValue = function(numMs) {
    return function(cutValueInput) {
      return setValue2(show3(floor2(numMs)))(cutValueInput);
    };
  };
  var rangeToNumberListener = function(rangeInput) {
    return function(numberInput) {
      return function(v) {
        return function __do5() {
          var rangeVal = value2(rangeInput)();
          return setValue2(rangeVal)(numberInput)();
        };
      };
    };
  };
  var numberToRangeListener = function(rangeInput) {
    return function(numberInput) {
      return function(v) {
        var nan2 = function(x) {
          return x !== x;
        };
        return function __do5() {
          var numVal = valueAsNumber(numberInput)();
          return when2(!nan2(numVal) && numVal >= 0)(setValue2(show3(floor2(numVal)))(rangeInput))();
        };
      };
    };
  };
  var setCutRangeHandlers = function(v) {
    return genericErrorsHandler(function __do5() {
      var cutStartEvL = eventListener(rangeToNumberListener(v.value0.cutStart)(v.value0.cutStartValue))();
      var cutEndEvL = eventListener(rangeToNumberListener(v.value0.cutEnd)(v.value0.cutEndValue))();
      var cutStartValueEvL = eventListener(numberToRangeListener(v.value0.cutStart)(v.value0.cutStartValue))();
      var cutEndValueEvL = eventListener(numberToRangeListener(v.value0.cutEnd)(v.value0.cutEndValue))();
      addEventListener(input)(cutStartEvL)(false)(toEventTarget2(toElement3(v.value0.cutStart)))();
      addEventListener(change)(cutStartEvL)(false)(toEventTarget2(toElement3(v.value0.cutStart)))();
      addEventListener(input)(cutEndEvL)(false)(toEventTarget2(toElement3(v.value0.cutEnd)))();
      addEventListener(change)(cutEndEvL)(false)(toEventTarget2(toElement3(v.value0.cutEnd)))();
      addEventListener(input)(cutStartValueEvL)(false)(toEventTarget2(toElement3(v.value0.cutStartValue)))();
      addEventListener(change)(cutStartValueEvL)(false)(toEventTarget2(toElement3(v.value0.cutStartValue)))();
      addEventListener(input)(cutEndValueEvL)(false)(toEventTarget2(toElement3(v.value0.cutEndValue)))();
      addEventListener(change)(cutEndValueEvL)(false)(toEventTarget2(toElement3(v.value0.cutEndValue)))();
      return unit;
    });
  };

  // output/Handers.YoutubeVideo.CutButtonsHandlers/index.js
  var discard2 = /* @__PURE__ */ discard(discardUnit);
  var show4 = /* @__PURE__ */ show(showInt);
  var discard22 = /* @__PURE__ */ discard2(bindAff);
  var whileM_2 = /* @__PURE__ */ whileM_(monadAff);
  var liftEffect3 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var map11 = /* @__PURE__ */ map(functorEffect);
  var not2 = /* @__PURE__ */ not(heytingAlgebraBoolean);
  var bind13 = /* @__PURE__ */ bind(bindAff);
  var setCutInputButtonEvL = function(cutInput) {
    return function(cutValueInput) {
      return function(v) {
        return function __do5() {
          var currentTimeSeconds = getPlayerCurrentTime();
          var currentTimeMs = currentTimeSeconds * 1e3;
          setValue2(show4(floor2(currentTimeMs)))(cutInput)();
          return updateCutValue(currentTimeMs)(cutValueInput)();
        };
      };
    };
  };
  var initializeCutInputs = function(cutStart) {
    return function(cutEnd) {
      return function(cutStartValue) {
        return function(cutEndValue) {
          return function(startTime) {
            return launchAff_(discard22(whileM_2(liftEffect3(map11(not2)(isPlayerReady)))(delay(500)))(function() {
              return bind13(liftEffect3(getVideoDuration))(function(durationSeconds) {
                var durationMs = durationSeconds * 1e3;
                var startTimeMs = toNumber(startTime) * 1e3;
                return discard22(liftEffect3(setMax(show4(floor2(durationMs)))(cutStart)))(function() {
                  return discard22(liftEffect3(setValue2(show4(floor2(startTimeMs)))(cutStart)))(function() {
                    return discard22(liftEffect3(setMax(show4(floor2(durationMs)))(cutEnd)))(function() {
                      return discard22(liftEffect3(updateCutValue(startTimeMs)(cutStartValue)))(function() {
                        return liftEffect3(updateCutValue(startTimeMs)(cutEndValue));
                      });
                    });
                  });
                });
              });
            }));
          };
        };
      };
    };
  };

  // output/Data.Array/foreign.js
  var replicateFill = function(count, value12) {
    if (count < 1) {
      return [];
    }
    var result = new Array(count);
    return result.fill(value12);
  };
  var replicatePolyfill = function(count, value12) {
    var result = [];
    var n = 0;
    for (var i = 0; i < count; i++) {
      result[n++] = value12;
    }
    return result;
  };
  var replicateImpl = typeof Array.prototype.fill === "function" ? replicateFill : replicatePolyfill;
  var length3 = function(xs) {
    return xs.length;
  };
  var unconsImpl = function(empty7, next2, xs) {
    return xs.length === 0 ? empty7({}) : next2(xs[0])(xs.slice(1));
  };
  var indexImpl = function(just, nothing, xs, i) {
    return i < 0 || i >= xs.length ? nothing : just(xs[i]);
  };
  var _updateAt = function(just, nothing, i, a, l) {
    if (i < 0 || i >= l.length) return nothing;
    var l1 = l.slice();
    l1[i] = a;
    return just(l1);
  };
  var filterImpl = function(f, xs) {
    return xs.filter(f);
  };
  var partitionImpl = function(f, xs) {
    var yes = [];
    var no = [];
    for (var i = 0; i < xs.length; i++) {
      var x = xs[i];
      if (f(x))
        yes.push(x);
      else
        no.push(x);
    }
    return { yes, no };
  };
  var sliceImpl = function(s, e, l) {
    return l.slice(s, e);
  };

  // output/Data.Array.ST/foreign.js
  function newSTArray() {
    return [];
  }
  function unsafeFreezeThawImpl(xs) {
    return xs;
  }
  var unsafeFreezeImpl = unsafeFreezeThawImpl;
  var pushImpl = function(a, xs) {
    return xs.push(a);
  };

  // output/Control.Monad.ST.Uncurried/foreign.js
  var runSTFn1 = function runSTFn12(fn) {
    return function(a) {
      return function() {
        return fn(a);
      };
    };
  };
  var runSTFn2 = function runSTFn22(fn) {
    return function(a) {
      return function(b) {
        return function() {
          return fn(a, b);
        };
      };
    };
  };

  // output/Data.Array.ST/index.js
  var unsafeFreeze = /* @__PURE__ */ runSTFn1(unsafeFreezeImpl);
  var push = /* @__PURE__ */ runSTFn2(pushImpl);

  // output/Data.Array.ST.Iterator/index.js
  var map12 = /* @__PURE__ */ map(functorST);
  var not3 = /* @__PURE__ */ not(heytingAlgebraBoolean);
  var $$void4 = /* @__PURE__ */ $$void(functorST);
  var Iterator = /* @__PURE__ */ function() {
    function Iterator2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    Iterator2.create = function(value0) {
      return function(value1) {
        return new Iterator2(value0, value1);
      };
    };
    return Iterator2;
  }();
  var next = function(v) {
    return function __do5() {
      var i = read2(v.value1)();
      modify(function(v1) {
        return v1 + 1 | 0;
      })(v.value1)();
      return v.value0(i);
    };
  };
  var iterator = function(f) {
    return map12(Iterator.create(f))(newSTRef(0));
  };
  var iterate = function(iter) {
    return function(f) {
      return function __do5() {
        var $$break = newSTRef(false)();
        while (map12(not3)(read2($$break))()) {
          (function __do6() {
            var mx = next(iter)();
            if (mx instanceof Just) {
              return f(mx.value0)();
            }
            ;
            if (mx instanceof Nothing) {
              return $$void4(write2(true)($$break))();
            }
            ;
            throw new Error("Failed pattern match at Data.Array.ST.Iterator (line 42, column 5 - line 44, column 47): " + [mx.constructor.name]);
          })();
        }
        ;
        return {};
      };
    };
  };

  // output/Data.Function.Uncurried/foreign.js
  var runFn2 = function(fn) {
    return function(a) {
      return function(b) {
        return fn(a, b);
      };
    };
  };
  var runFn3 = function(fn) {
    return function(a) {
      return function(b) {
        return function(c) {
          return fn(a, b, c);
        };
      };
    };
  };
  var runFn4 = function(fn) {
    return function(a) {
      return function(b) {
        return function(c) {
          return function(d) {
            return fn(a, b, c, d);
          };
        };
      };
    };
  };
  var runFn5 = function(fn) {
    return function(a) {
      return function(b) {
        return function(c) {
          return function(d) {
            return function(e) {
              return fn(a, b, c, d, e);
            };
          };
        };
      };
    };
  };

  // output/Data.Array/index.js
  var append2 = /* @__PURE__ */ append(semigroupArray);
  var updateAt = /* @__PURE__ */ function() {
    return runFn5(_updateAt)(Just.create)(Nothing.value);
  }();
  var tail = /* @__PURE__ */ function() {
    return runFn3(unconsImpl)($$const(Nothing.value))(function(v) {
      return function(xs) {
        return new Just(xs);
      };
    });
  }();
  var slice = /* @__PURE__ */ runFn3(sliceImpl);
  var take = function(n) {
    return function(xs) {
      var $152 = n < 1;
      if ($152) {
        return [];
      }
      ;
      return slice(0)(n)(xs);
    };
  };
  var singleton4 = function(a) {
    return [a];
  };
  var replicate = /* @__PURE__ */ runFn2(replicateImpl);
  var partition = /* @__PURE__ */ runFn2(partitionImpl);
  var $$null3 = function(xs) {
    return length3(xs) === 0;
  };
  var index2 = /* @__PURE__ */ function() {
    return runFn4(indexImpl)(Just.create)(Nothing.value);
  }();
  var last = function(xs) {
    return index2(xs)(length3(xs) - 1 | 0);
  };
  var modifyAt = function(i) {
    return function(f) {
      return function(xs) {
        var go2 = function(x) {
          return updateAt(i)(f(x))(xs);
        };
        return maybe(Nothing.value)(go2)(index2(xs)(i));
      };
    };
  };
  var span2 = function(p) {
    return function(arr) {
      var go2 = function($copy_i) {
        var $tco_done = false;
        var $tco_result;
        function $tco_loop(i) {
          var v = index2(arr)(i);
          if (v instanceof Just) {
            var $156 = p(v.value0);
            if ($156) {
              $copy_i = i + 1 | 0;
              return;
            }
            ;
            $tco_done = true;
            return new Just(i);
          }
          ;
          if (v instanceof Nothing) {
            $tco_done = true;
            return Nothing.value;
          }
          ;
          throw new Error("Failed pattern match at Data.Array (line 1035, column 5 - line 1037, column 25): " + [v.constructor.name]);
        }
        ;
        while (!$tco_done) {
          $tco_result = $tco_loop($copy_i);
        }
        ;
        return $tco_result;
      };
      var breakIndex = go2(0);
      if (breakIndex instanceof Just && breakIndex.value0 === 0) {
        return {
          init: [],
          rest: arr
        };
      }
      ;
      if (breakIndex instanceof Just) {
        return {
          init: slice(0)(breakIndex.value0)(arr),
          rest: slice(breakIndex.value0)(length3(arr))(arr)
        };
      }
      ;
      if (breakIndex instanceof Nothing) {
        return {
          init: arr,
          rest: []
        };
      }
      ;
      throw new Error("Failed pattern match at Data.Array (line 1022, column 3 - line 1028, column 30): " + [breakIndex.constructor.name]);
    };
  };
  var head = function(xs) {
    return index2(xs)(0);
  };
  var filter = /* @__PURE__ */ runFn2(filterImpl);
  var drop = function(n) {
    return function(xs) {
      var $173 = n < 1;
      if ($173) {
        return xs;
      }
      ;
      return slice(n)(length3(xs))(xs);
    };
  };
  var cons = function(x) {
    return function(xs) {
      return append2([x])(xs);
    };
  };
  var concatMap = /* @__PURE__ */ flip(/* @__PURE__ */ bind(bindArray));
  var mapMaybe = function(f) {
    return concatMap(function() {
      var $189 = maybe([])(singleton4);
      return function($190) {
        return $189(f($190));
      };
    }());
  };
  var catMaybes = /* @__PURE__ */ mapMaybe(/* @__PURE__ */ identity(categoryFn));

  // output/Data.String.CodeUnits/foreign.js
  var fromCharArray = function(a) {
    return a.join("");
  };
  var toCharArray = function(s) {
    return s.split("");
  };
  var singleton5 = function(c) {
    return c;
  };

  // output/Data.String.Unsafe/foreign.js
  var char = function(s) {
    if (s.length === 1) return s.charAt(0);
    throw new Error("Data.String.Unsafe.char: Expected string of length 1.");
  };

  // output/Conversion.Time/index.js
  var show5 = /* @__PURE__ */ show(showNumber);
  var identity8 = /* @__PURE__ */ identity(categoryFn);
  var append3 = /* @__PURE__ */ append(semigroupArray);
  var formatToThreeDecimals = function(v) {
    var v1 = span2(function(x) {
      return x !== ".";
    })(toCharArray(show5(v)));
    var num = fromCharArray(v1.init);
    var decChars = maybe([])(identity8)(tail(v1.rest));
    var dec3 = take(3)(append3(decChars)(replicate(3)("0")));
    var dec = fromCharArray(dec3);
    return num + ("." + dec);
  };

  // output/Handers.YoutubeVideo.PlaybackPositionHandler/index.js
  var when3 = /* @__PURE__ */ when(applicativeEffect);
  var updatePlaybackPosition = function(playbackPosition) {
    return function __do5() {
      var playerReady = isPlayerReady();
      var currentTime2 = getPlayerCurrentTime();
      return when3(playerReady)(setTextContent(formatToThreeDecimals(currentTime2))(toNode2(playbackPosition)))();
    };
  };

  // output/Data.Array.NonEmpty/index.js
  var toArray = function(v) {
    return v;
  };
  var adaptAny = function(f) {
    return function($128) {
      return f(toArray($128));
    };
  };
  var index3 = /* @__PURE__ */ adaptAny(index2);

  // output/Data.String.Regex/foreign.js
  var regexImpl = function(left) {
    return function(right) {
      return function(s1) {
        return function(s2) {
          try {
            return right(new RegExp(s1, s2));
          } catch (e) {
            return left(e.message);
          }
        };
      };
    };
  };
  var test = function(r) {
    return function(s) {
      var lastIndex = r.lastIndex;
      var result = r.test(s);
      r.lastIndex = lastIndex;
      return result;
    };
  };
  var _match = function(just) {
    return function(nothing) {
      return function(r) {
        return function(s) {
          var m = s.match(r);
          if (m == null || m.length === 0) {
            return nothing;
          } else {
            for (var i = 0; i < m.length; i++) {
              m[i] = m[i] == null ? nothing : just(m[i]);
            }
            return just(m);
          }
        };
      };
    };
  };

  // output/Data.String.Regex.Flags/index.js
  var noFlags = {
    global: false,
    ignoreCase: false,
    multiline: false,
    dotAll: false,
    sticky: false,
    unicode: false
  };

  // output/Data.String.Regex/index.js
  var renderFlags = function(v) {
    return function() {
      if (v.global) {
        return "g";
      }
      ;
      return "";
    }() + (function() {
      if (v.ignoreCase) {
        return "i";
      }
      ;
      return "";
    }() + (function() {
      if (v.multiline) {
        return "m";
      }
      ;
      return "";
    }() + (function() {
      if (v.dotAll) {
        return "s";
      }
      ;
      return "";
    }() + (function() {
      if (v.sticky) {
        return "y";
      }
      ;
      return "";
    }() + function() {
      if (v.unicode) {
        return "u";
      }
      ;
      return "";
    }()))));
  };
  var regex = function(s) {
    return function(f) {
      return regexImpl(Left.create)(Right.create)(s)(renderFlags(f));
    };
  };
  var match = /* @__PURE__ */ function() {
    return _match(Just.create)(Nothing.value);
  }();

  // output/Data.URL/foreign.js
  var fromStringImpl2 = (s) => {
    try {
      return new URL(s);
    } catch {
      return null;
    }
  };
  var hrefImpl = (u) => u.href;
  var pathnameImpl = (u) => u.pathname;
  var queryKeysImpl = (u) => Array.from(u.searchParams.keys());
  var queryLookupImpl = (k) => (u) => u.searchParams.getAll(k);

  // output/Data.Compactable/index.js
  var $$void5 = /* @__PURE__ */ $$void(functorST);
  var pure1 = /* @__PURE__ */ pure(applicativeST);
  var apply4 = /* @__PURE__ */ apply(applyST);
  var map13 = /* @__PURE__ */ map(functorST);
  var compactableMaybe = {
    compact: /* @__PURE__ */ join(bindMaybe),
    separate: function(v) {
      if (v instanceof Nothing) {
        return {
          left: Nothing.value,
          right: Nothing.value
        };
      }
      ;
      if (v instanceof Just) {
        if (v.value0 instanceof Left) {
          return {
            left: new Just(v.value0.value0),
            right: Nothing.value
          };
        }
        ;
        if (v.value0 instanceof Right) {
          return {
            left: Nothing.value,
            right: new Just(v.value0.value0)
          };
        }
        ;
        throw new Error("Failed pattern match at Data.Compactable (line 91, column 23 - line 93, column 48): " + [v.value0.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Data.Compactable (line 87, column 1 - line 93, column 48): " + [v.constructor.name]);
    }
  };
  var compactableArray = {
    compact: function(xs) {
      return function __do5() {
        var result = newSTArray();
        var iter = iterator(function(v) {
          return index2(xs)(v);
        })();
        iterate(iter)(function($108) {
          return $$void5(function(v) {
            if (v instanceof Nothing) {
              return pure1(0);
            }
            ;
            if (v instanceof Just) {
              return push(v.value0)(result);
            }
            ;
            throw new Error("Failed pattern match at Data.Compactable (line 111, column 34 - line 113, column 35): " + [v.constructor.name]);
          }($108));
        })();
        return unsafeFreeze(result)();
      }();
    },
    separate: function(xs) {
      return function __do5() {
        var ls = newSTArray();
        var rs = newSTArray();
        var iter = iterator(function(v) {
          return index2(xs)(v);
        })();
        iterate(iter)(function($109) {
          return $$void5(function(v) {
            if (v instanceof Left) {
              return push(v.value0)(ls);
            }
            ;
            if (v instanceof Right) {
              return push(v.value0)(rs);
            }
            ;
            throw new Error("Failed pattern match at Data.Compactable (line 122, column 34 - line 124, column 31): " + [v.constructor.name]);
          }($109));
        })();
        return apply4(map13(function(v) {
          return function(v1) {
            return {
              left: v,
              right: v1
            };
          };
        })(unsafeFreeze(ls)))(unsafeFreeze(rs))();
      }();
    }
  };

  // output/Data.Filterable/index.js
  var append4 = /* @__PURE__ */ append(semigroupArray);
  var foldl2 = /* @__PURE__ */ foldl(foldableArray);
  var partitionMap = function(dict) {
    return dict.partitionMap;
  };
  var maybeBool = function(p) {
    return function(x) {
      var $66 = p(x);
      if ($66) {
        return new Just(x);
      }
      ;
      return Nothing.value;
    };
  };
  var filterableArray = {
    partitionMap: function(p) {
      var go2 = function(acc) {
        return function(x) {
          var v = p(x);
          if (v instanceof Left) {
            return {
              right: acc.right,
              left: append4(acc.left)([v.value0])
            };
          }
          ;
          if (v instanceof Right) {
            return {
              left: acc.left,
              right: append4(acc.right)([v.value0])
            };
          }
          ;
          throw new Error("Failed pattern match at Data.Filterable (line 149, column 16 - line 151, column 50): " + [v.constructor.name]);
        };
      };
      return foldl2(go2)({
        left: [],
        right: []
      });
    },
    partition,
    filterMap: mapMaybe,
    filter,
    Compactable0: function() {
      return compactableArray;
    },
    Functor1: function() {
      return functorArray;
    }
  };
  var filterMap = function(dict) {
    return dict.filterMap;
  };
  var filterDefault = function(dictFilterable) {
    var $121 = filterMap(dictFilterable);
    return function($122) {
      return $121(maybeBool($122));
    };
  };
  var filter3 = function(dict) {
    return dict.filter;
  };
  var eitherBool = function(p) {
    return function(x) {
      var $84 = p(x);
      if ($84) {
        return new Right(x);
      }
      ;
      return new Left(x);
    };
  };
  var partitionDefault = function(dictFilterable) {
    var partitionMap1 = partitionMap(dictFilterable);
    return function(p) {
      return function(xs) {
        var o = partitionMap1(eitherBool(p))(xs);
        return {
          no: o.left,
          yes: o.right
        };
      };
    };
  };
  var filterableMaybe = {
    partitionMap: function(v) {
      return function(v1) {
        if (v1 instanceof Nothing) {
          return {
            left: Nothing.value,
            right: Nothing.value
          };
        }
        ;
        if (v1 instanceof Just) {
          var v2 = v(v1.value0);
          if (v2 instanceof Left) {
            return {
              left: new Just(v2.value0),
              right: Nothing.value
            };
          }
          ;
          if (v2 instanceof Right) {
            return {
              left: Nothing.value,
              right: new Just(v2.value0)
            };
          }
          ;
          throw new Error("Failed pattern match at Data.Filterable (line 161, column 29 - line 163, column 48): " + [v2.constructor.name]);
        }
        ;
        throw new Error("Failed pattern match at Data.Filterable (line 159, column 1 - line 169, column 29): " + [v.constructor.name, v1.constructor.name]);
      };
    },
    partition: function(p) {
      return partitionDefault(filterableMaybe)(p);
    },
    filterMap: /* @__PURE__ */ bindFlipped(bindMaybe),
    filter: function(p) {
      return filterDefault(filterableMaybe)(p);
    },
    Compactable0: function() {
      return compactableMaybe;
    },
    Functor1: function() {
      return functorMaybe;
    }
  };

  // output/Data.String.Utils/foreign.js
  function startsWithImpl(searchString, s) {
    return s.startsWith(searchString);
  }

  // output/Data.String.CodePoints/foreign.js
  var hasArrayFrom = typeof Array.from === "function";
  var hasStringIterator = typeof Symbol !== "undefined" && Symbol != null && typeof Symbol.iterator !== "undefined" && typeof String.prototype[Symbol.iterator] === "function";
  var hasFromCodePoint = typeof String.prototype.fromCodePoint === "function";
  var hasCodePointAt = typeof String.prototype.codePointAt === "function";

  // output/Data.String.Utils/index.js
  var startsWith = function(searchString) {
    return function(s) {
      return startsWithImpl(searchString, s);
    };
  };

  // output/Foreign/foreign.js
  function typeOf(value12) {
    return typeof value12;
  }
  function tagOf(value12) {
    return Object.prototype.toString.call(value12).slice(8, -1);
  }
  var isArray = Array.isArray || function(value12) {
    return Object.prototype.toString.call(value12) === "[object Array]";
  };

  // output/Data.List.NonEmpty/index.js
  var singleton6 = /* @__PURE__ */ function() {
    var $200 = singleton2(plusList);
    return function($201) {
      return NonEmptyList($200($201));
    };
  }();

  // output/Foreign/index.js
  var show6 = /* @__PURE__ */ show(showString);
  var show1 = /* @__PURE__ */ show(showInt);
  var ForeignError = /* @__PURE__ */ function() {
    function ForeignError2(value0) {
      this.value0 = value0;
    }
    ;
    ForeignError2.create = function(value0) {
      return new ForeignError2(value0);
    };
    return ForeignError2;
  }();
  var TypeMismatch = /* @__PURE__ */ function() {
    function TypeMismatch2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    TypeMismatch2.create = function(value0) {
      return function(value1) {
        return new TypeMismatch2(value0, value1);
      };
    };
    return TypeMismatch2;
  }();
  var ErrorAtIndex = /* @__PURE__ */ function() {
    function ErrorAtIndex2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ErrorAtIndex2.create = function(value0) {
      return function(value1) {
        return new ErrorAtIndex2(value0, value1);
      };
    };
    return ErrorAtIndex2;
  }();
  var ErrorAtProperty = /* @__PURE__ */ function() {
    function ErrorAtProperty2(value0, value1) {
      this.value0 = value0;
      this.value1 = value1;
    }
    ;
    ErrorAtProperty2.create = function(value0) {
      return function(value1) {
        return new ErrorAtProperty2(value0, value1);
      };
    };
    return ErrorAtProperty2;
  }();
  var unsafeToForeign = unsafeCoerce2;
  var unsafeFromForeign = unsafeCoerce2;
  var showForeignError = {
    show: function(v) {
      if (v instanceof ForeignError) {
        return "(ForeignError " + (show6(v.value0) + ")");
      }
      ;
      if (v instanceof ErrorAtIndex) {
        return "(ErrorAtIndex " + (show1(v.value0) + (" " + (show(showForeignError)(v.value1) + ")")));
      }
      ;
      if (v instanceof ErrorAtProperty) {
        return "(ErrorAtProperty " + (show6(v.value0) + (" " + (show(showForeignError)(v.value1) + ")")));
      }
      ;
      if (v instanceof TypeMismatch) {
        return "(TypeMismatch " + (show6(v.value0) + (" " + (show6(v.value1) + ")")));
      }
      ;
      throw new Error("Failed pattern match at Foreign (line 69, column 1 - line 73, column 89): " + [v.constructor.name]);
    }
  };
  var fail = function(dictMonad) {
    var $153 = throwError(monadThrowExceptT(dictMonad));
    return function($154) {
      return $153(singleton6($154));
    };
  };
  var readArray = function(dictMonad) {
    var pure110 = pure(applicativeExceptT(dictMonad));
    var fail1 = fail(dictMonad);
    return function(value12) {
      if (isArray(value12)) {
        return pure110(unsafeFromForeign(value12));
      }
      ;
      if (otherwise) {
        return fail1(new TypeMismatch("array", tagOf(value12)));
      }
      ;
      throw new Error("Failed pattern match at Foreign (line 164, column 1 - line 164, column 99): " + [value12.constructor.name]);
    };
  };
  var unsafeReadTagged = function(dictMonad) {
    var pure110 = pure(applicativeExceptT(dictMonad));
    var fail1 = fail(dictMonad);
    return function(tag) {
      return function(value12) {
        if (tagOf(value12) === tag) {
          return pure110(unsafeFromForeign(value12));
        }
        ;
        if (otherwise) {
          return fail1(new TypeMismatch(tag, tagOf(value12)));
        }
        ;
        throw new Error("Failed pattern match at Foreign (line 123, column 1 - line 123, column 104): " + [tag.constructor.name, value12.constructor.name]);
      };
    };
  };
  var readString = function(dictMonad) {
    return unsafeReadTagged(dictMonad)("String");
  };

  // output/Control.Monad.Except/index.js
  var unwrap2 = /* @__PURE__ */ unwrap();
  var withExcept = /* @__PURE__ */ withExceptT(functorIdentity);
  var runExcept = function($3) {
    return unwrap2(runExceptT($3));
  };

  // output/Foreign.Index/foreign.js
  function unsafeReadPropImpl(f, s, key2, value12) {
    return value12 == null ? f : s(value12[key2]);
  }

  // output/Foreign.Index/index.js
  var unsafeReadProp = function(dictMonad) {
    var fail3 = fail(dictMonad);
    var pure24 = pure(applicativeExceptT(dictMonad));
    return function(k) {
      return function(value12) {
        return unsafeReadPropImpl(fail3(new TypeMismatch("object", typeOf(value12))), pure24, k, value12);
      };
    };
  };
  var readProp = function(dictMonad) {
    return unsafeReadProp(dictMonad);
  };

  // output/Foreign.Object/foreign.js
  function toArrayWithKey(f) {
    return function(m) {
      var r = [];
      for (var k in m) {
        if (hasOwnProperty.call(m, k)) {
          r.push(f(k)(m[k]));
        }
      }
      return r;
    };
  }
  var keys = Object.keys || toArrayWithKey(function(k) {
    return function() {
      return k;
    };
  });

  // output/Record/index.js
  var insert3 = function(dictIsSymbol) {
    var reflectSymbol2 = reflectSymbol(dictIsSymbol);
    return function() {
      return function() {
        return function(l) {
          return function(a) {
            return function(r) {
              return unsafeSet(reflectSymbol2(l))(a)(r);
            };
          };
        };
      };
    };
  };
  var get = function(dictIsSymbol) {
    var reflectSymbol2 = reflectSymbol(dictIsSymbol);
    return function() {
      return function(l) {
        return function(r) {
          return unsafeGet(reflectSymbol2(l))(r);
        };
      };
    };
  };
  var $$delete2 = function(dictIsSymbol) {
    var reflectSymbol2 = reflectSymbol(dictIsSymbol);
    return function() {
      return function() {
        return function(l) {
          return function(r) {
            return unsafeDelete(reflectSymbol2(l))(r);
          };
        };
      };
    };
  };

  // output/Record.Builder/foreign.js
  function copyRecord(rec) {
    var copy = {};
    for (var key2 in rec) {
      if ({}.hasOwnProperty.call(rec, key2)) {
        copy[key2] = rec[key2];
      }
    }
    return copy;
  }
  function unsafeInsert(l) {
    return function(a) {
      return function(rec) {
        rec[l] = a;
        return rec;
      };
    };
  }

  // output/Record.Builder/index.js
  var semigroupoidBuilder = semigroupoidFn;
  var insert4 = function() {
    return function() {
      return function(dictIsSymbol) {
        var reflectSymbol2 = reflectSymbol(dictIsSymbol);
        return function(l) {
          return function(a) {
            return function(r1) {
              return unsafeInsert(reflectSymbol2(l))(a)(r1);
            };
          };
        };
      };
    };
  };
  var categoryBuilder = categoryFn;
  var build = function(v) {
    return function(r1) {
      return v(copyRecord(r1));
    };
  };

  // output/Data.URL/index.js
  var filter4 = /* @__PURE__ */ filter3(filterableMaybe);
  var fromFoldable4 = /* @__PURE__ */ fromFoldable(ordString)(foldableArray);
  var map14 = /* @__PURE__ */ map(functorArray);
  var wrap3 = /* @__PURE__ */ wrap();
  var filter1 = /* @__PURE__ */ filter3(filterableArray);
  var PathEmpty = /* @__PURE__ */ function() {
    function PathEmpty2() {
    }
    ;
    PathEmpty2.value = new PathEmpty2();
    return PathEmpty2;
  }();
  var PathAbsolute = /* @__PURE__ */ function() {
    function PathAbsolute2(value0) {
      this.value0 = value0;
    }
    ;
    PathAbsolute2.create = function(value0) {
      return new PathAbsolute2(value0);
    };
    return PathAbsolute2;
  }();
  var PathRelative = /* @__PURE__ */ function() {
    function PathRelative2(value0) {
      this.value0 = value0;
    }
    ;
    PathRelative2.create = function(value0) {
      return new PathRelative2(value0);
    };
    return PathRelative2;
  }();
  var toString = hrefImpl;
  var query = function(u) {
    var vals = function(k) {
      return queryLookupImpl(k)(u);
    };
    var ks = queryKeysImpl(u);
    return fromFoldable4(map14(function(k) {
      return new Tuple(k, vals(k));
    })(ks));
  };
  var pathFromString = function(s) {
    var segments = function() {
      var $235 = filter1(function($238) {
        return !$$null2($238);
      });
      var $236 = split(wrap3("/"));
      return function($237) {
        return $235($236($237));
      };
    }();
    return maybe(PathEmpty.value)(function() {
      var $203 = startsWith("/")(s);
      if ($203) {
        return PathAbsolute.create;
      }
      ;
      return PathRelative.create;
    }())(filter4(function($239) {
      return !$$null3($239);
    })(new Just(segments(s))));
  };
  var path = function($240) {
    return pathFromString(pathnameImpl($240));
  };
  var fromString2 = function($255) {
    return toMaybe(fromStringImpl2($255));
  };

  // output/Handers.YoutubeVideo.YoutubeUrlExtraction/index.js
  var join2 = /* @__PURE__ */ join(bindMaybe);
  var bind2 = /* @__PURE__ */ bind(bindMaybe);
  var lookup3 = /* @__PURE__ */ lookup(ordString);
  var alt5 = /* @__PURE__ */ alt(altMaybe);
  var pathToArray = function(v) {
    if (v instanceof PathEmpty) {
      return [];
    }
    ;
    if (v instanceof PathAbsolute) {
      return v.value0;
    }
    ;
    if (v instanceof PathRelative) {
      return v.value0;
    }
    ;
    throw new Error("Failed pattern match at Handers.YoutubeVideo.YoutubeUrlExtraction (line 23, column 1 - line 23, column 36): " + [v.constructor.name]);
  };
  var parseUnit = function(str) {
    return function(unit2) {
      var v = regex("(\\d+)" + unit2)(noFlags);
      if (v instanceof Left) {
        return 0;
      }
      ;
      if (v instanceof Right) {
        var v1 = join2(bind2(match(v.value0)(str))(flip(index3)(1)));
        if (v1 instanceof Just) {
          return fromMaybe(0)(fromString(v1.value0));
        }
        ;
        if (v1 instanceof Nothing) {
          return 0;
        }
        ;
        throw new Error("Failed pattern match at Handers.YoutubeVideo.YoutubeUrlExtraction (line 39, column 7 - line 41, column 21): " + [v1.constructor.name]);
      }
      ;
      throw new Error("Failed pattern match at Handers.YoutubeVideo.YoutubeUrlExtraction (line 36, column 3 - line 41, column 21): " + [v.constructor.name]);
    };
  };
  var parseYouTubeT = function(raw) {
    var str = toLower(raw);
    var v = fromString(str);
    if (v instanceof Just) {
      return new Just(v.value0);
    }
    ;
    if (v instanceof Nothing) {
      var s = parseUnit(str)("s");
      var m = parseUnit(str)("m");
      var h = parseUnit(str)("h");
      var total = ((h * 3600 | 0) + (m * 60 | 0) | 0) + s | 0;
      var $24 = total > 0;
      if ($24) {
        return new Just(total);
      }
      ;
      return Nothing.value;
    }
    ;
    throw new Error("Failed pattern match at Handers.YoutubeVideo.YoutubeUrlExtraction (line 49, column 5 - line 58, column 52): " + [v.constructor.name]);
  };
  var extractYoutubeVideoStartTime = function(url3) {
    return fromMaybe(0)(bind2(lookup3("t")(query(url3)))(function(values) {
      return bind2(head(values))(function(v) {
        return parseYouTubeT(v);
      });
    }));
  };
  var extractYoutubeVideoId = function(url3) {
    var maybeVQueryString = function(v) {
      return bind2(lookup3("v")(v))(head);
    }(query(url3));
    var lastPath = function($25) {
      return last(pathToArray($25));
    }(path(url3));
    return alt5(maybeVQueryString)(lastPath);
  };

  // output/Model.ValidationErrors/index.js
  var union3 = /* @__PURE__ */ union(ordString);
  var semigroupValidationErrors = {
    append: function(v) {
      return function(v1) {
        return union3(v)(v1);
      };
    }
  };
  var toMap = function(v) {
    return v;
  };
  var fromSingleton = function(k) {
    return function(v) {
      return singleton3(k)(v);
    };
  };

  // output/Validations.RegexValidation/index.js
  var pure4 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeV(semigroupValidationErrors));
  var matches2 = function(v) {
    return function(v1) {
      return function(v2) {
        if (test(v)(v2)) {
          return pure4(v2);
        }
        ;
        return invalid(fromSingleton(v1)("Invalid Input for regex: " + v2));
      };
    };
  };

  // output/Validations.YoutubeValidation/index.js
  var lmap2 = /* @__PURE__ */ lmap(bifunctorEither);
  var lmap1 = /* @__PURE__ */ lmap(bifunctorV);
  var pure5 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeV(semigroupValidationErrors));
  var youtubeRegex = "^(?:https?:\\/\\/)?(?:www\\.)?(?:youtube\\.com\\/watch\\?v=([a-zA-Z0-9_-]+)|youtu\\.be\\/([a-zA-Z\\d_-]+))(?:[?&].*)?$";
  var youtubeRegexValidation = function(id2) {
    return lmap2(function(x) {
      return fromSingleton(id2)(x);
    })(regex(youtubeRegex)(noFlags));
  };
  var youtubeUrlValidation = function(id2) {
    return function(v) {
      return lmap1(function(v1) {
        return fromSingleton(id2)("Invalid Youtube URL");
      })(andThen(andThen(youtubeRegexValidation(id2))(function(ytRegex) {
        return matches2(ytRegex)(id2)(v);
      }))(function(urlString) {
        return maybe(invalid(fromSingleton(id2)("Error validating youtube Url")))(pure5)(fromString2(urlString));
      }));
    };
  };

  // output/Web.Event.Event/foreign.js
  function _target(e) {
    return e.target;
  }
  function preventDefault(e) {
    return function() {
      return e.preventDefault();
    };
  }

  // output/Web.Event.Event/index.js
  var target5 = function($3) {
    return toMaybe(_target($3));
  };

  // output/Handers.YoutubeVideo.YoutubeVideoHandler/index.js
  var traverse3 = /* @__PURE__ */ traverse(traversableMaybe)(applicativeEffect);
  var bind3 = /* @__PURE__ */ bind(bindMaybe);
  var foldl3 = /* @__PURE__ */ foldl(foldableV);
  var pure6 = /* @__PURE__ */ pure(applicativeEffect);
  var show7 = /* @__PURE__ */ show(/* @__PURE__ */ showMaybe(showString));
  var show12 = /* @__PURE__ */ show(showString);
  var VET = /* @__PURE__ */ function() {
    function VET2(value0) {
      this.value0 = value0;
    }
    ;
    VET2.create = function(value0) {
      return new VET2(value0);
    };
    return VET2;
  }();
  var getInputValue = function(ev) {
    return traverse3(value2)(bind3(bind3(target5(ev))(fromEventTarget2))(fromElement4));
  };
  var youtubeUrlEventListener = function(cutStart) {
    return function(cutEnd) {
      return function(cutStartValue) {
        return function(cutEndValue) {
          return function(ev) {
            return function __do5() {
              var rawValue = getInputValue(ev)();
              var youtubeUrlV = maybe(invalid(fromSingleton(youtubeUrlId)("Empty YoutubeUrl Input")))(function(v) {
                return youtubeUrlValidation(youtubeUrlId)(v);
              })(rawValue);
              var youtubeUrl = foldl3(function(v) {
                return function(v1) {
                  return pure6(v1);
                };
              })(throwMinsiError(new InvalidInput(youtubeUrlId, show7(rawValue))))(youtubeUrlV)();
              var videoId = maybe(throwMinsiError(new InvalidInput(youtubeUrlId, show7(rawValue))))(pure6)(extractYoutubeVideoId(youtubeUrl))();
              var startTime = extractYoutubeVideoStartTime(youtubeUrl);
              log("Youtube Url Handler fired with value: " + show12(videoId))();
              embedVideo({
                resultPreviewId,
                videoId,
                width: 1e3,
                height: 500,
                startTime
              })();
              return initializeCutInputs(cutStart)(cutEnd)(cutStartValue)(cutEndValue)(startTime)();
            };
          };
        };
      };
    };
  };
  var setVideoHandlers = function(v) {
    var ytUrlEventTarget = toEventTarget2(toElement3(v.value0.youtubeUrl));
    var setCutStartButtonTarget = toEventTarget2(toElement(v.value0.setCutStartButton));
    var setCutEndButtonTarget = toEventTarget2(toElement(v.value0.setCutEndButton));
    return genericErrorsHandler(function __do5() {
      var ytEvL = eventListener(youtubeUrlEventListener(v.value0.cutStart)(v.value0.cutEnd)(v.value0.cutStartValue)(v.value0.cutEndValue))();
      addEventListener(input)(ytEvL)(false)(ytUrlEventTarget)();
      addEventListener(change)(ytEvL)(false)(ytUrlEventTarget)();
      setInterval2(1e3)(updatePlaybackPosition(v.value0.playbackPositionYoutube))();
      var setCutStartButtonEvLV = eventListener(setCutInputButtonEvL(v.value0.cutStart)(v.value0.cutStartValue))();
      var setCutEndButtonEvLV = eventListener(setCutInputButtonEvL(v.value0.cutEnd)(v.value0.cutEndValue))();
      addEventListener(click2)(setCutStartButtonEvLV)(false)(setCutStartButtonTarget)();
      addEventListener(click2)(setCutEndButtonEvLV)(false)(setCutEndButtonTarget)();
      return unit;
    });
  };

  // output/Web.DOM.HTMLCollection/foreign.js
  function toArray2(list) {
    return function() {
      return [].slice.call(list);
    };
  }

  // output/Components.HTMLTableElement/index.js
  var pure7 = /* @__PURE__ */ pure(applicativeEffect);
  var bind14 = /* @__PURE__ */ bind(bindMaybe);
  var map15 = /* @__PURE__ */ map(functorArray);
  var getTBody = function(table) {
    return function __do5() {
      var tBodies2 = tBodies(table)();
      var tBodyArray = toArray2(tBodies2)();
      return maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableBody")))(pure7)(bind14(head(tBodyArray))(fromElement13))();
    };
  };
  var getStartInput = function(row) {
    return function __do5() {
      var cells2 = cells(row)();
      var cellArray = toArray2(cells2)();
      var startCell = maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableStartCell")))(pure7)(bind14(head(cellArray))(fromElement11))();
      var element = toElement6(startCell);
      var parentNode2 = toParentNode(element);
      var elementMaybe = querySelector("input")(parentNode2)();
      var input2 = maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableStartInput")))(pure7)(bind14(elementMaybe)(fromElement4))();
      return input2;
    };
  };
  var getRows = function(table) {
    return function __do5() {
      var tbody = getTBody(table)();
      var rows4 = rows2(tbody)();
      var rowArray = toArray2(rows4)();
      return catMaybes(map15(fromElement12)(rowArray));
    };
  };
  var getFirstRow = function(table) {
    return function __do5() {
      var rows4 = getRows(table)();
      return maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableFirstRow")))(pure7)(head(rows4))();
    };
  };
  var getEndInput = function(row) {
    return function __do5() {
      var cells2 = cells(row)();
      var cellArray = toArray2(cells2)();
      var endCell = maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableEndCell")))(pure7)(bind14(head(drop(1)(cellArray)))(fromElement11))();
      var element = toElement6(endCell);
      var parentNode2 = toParentNode(element);
      var elementMaybe = querySelector("input")(parentNode2)();
      var input2 = maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableEndInput")))(pure7)(bind14(elementMaybe)(fromElement4))();
      return input2;
    };
  };

  // output/Constants/index.js
  var outputPath = "/output/";
  var mp4 = function(filename) {
    return outputPath + (filename + ".mp4");
  };
  var gif = function(filename) {
    return outputPath + (filename + "Gif.mp4");
  };

  // output/Data.DateTime.Instant/index.js
  var unInstant = function(v) {
    return v;
  };

  // output/Effect.Now/foreign.js
  function now() {
    return Date.now();
  }

  // output/Data.HTTP.Method/index.js
  var OPTIONS = /* @__PURE__ */ function() {
    function OPTIONS2() {
    }
    ;
    OPTIONS2.value = new OPTIONS2();
    return OPTIONS2;
  }();
  var GET = /* @__PURE__ */ function() {
    function GET2() {
    }
    ;
    GET2.value = new GET2();
    return GET2;
  }();
  var HEAD = /* @__PURE__ */ function() {
    function HEAD2() {
    }
    ;
    HEAD2.value = new HEAD2();
    return HEAD2;
  }();
  var POST = /* @__PURE__ */ function() {
    function POST2() {
    }
    ;
    POST2.value = new POST2();
    return POST2;
  }();
  var PUT = /* @__PURE__ */ function() {
    function PUT2() {
    }
    ;
    PUT2.value = new PUT2();
    return PUT2;
  }();
  var DELETE = /* @__PURE__ */ function() {
    function DELETE2() {
    }
    ;
    DELETE2.value = new DELETE2();
    return DELETE2;
  }();
  var TRACE = /* @__PURE__ */ function() {
    function TRACE2() {
    }
    ;
    TRACE2.value = new TRACE2();
    return TRACE2;
  }();
  var CONNECT = /* @__PURE__ */ function() {
    function CONNECT2() {
    }
    ;
    CONNECT2.value = new CONNECT2();
    return CONNECT2;
  }();
  var PROPFIND = /* @__PURE__ */ function() {
    function PROPFIND2() {
    }
    ;
    PROPFIND2.value = new PROPFIND2();
    return PROPFIND2;
  }();
  var PROPPATCH = /* @__PURE__ */ function() {
    function PROPPATCH2() {
    }
    ;
    PROPPATCH2.value = new PROPPATCH2();
    return PROPPATCH2;
  }();
  var MKCOL = /* @__PURE__ */ function() {
    function MKCOL2() {
    }
    ;
    MKCOL2.value = new MKCOL2();
    return MKCOL2;
  }();
  var COPY = /* @__PURE__ */ function() {
    function COPY2() {
    }
    ;
    COPY2.value = new COPY2();
    return COPY2;
  }();
  var MOVE = /* @__PURE__ */ function() {
    function MOVE2() {
    }
    ;
    MOVE2.value = new MOVE2();
    return MOVE2;
  }();
  var LOCK = /* @__PURE__ */ function() {
    function LOCK2() {
    }
    ;
    LOCK2.value = new LOCK2();
    return LOCK2;
  }();
  var UNLOCK = /* @__PURE__ */ function() {
    function UNLOCK2() {
    }
    ;
    UNLOCK2.value = new UNLOCK2();
    return UNLOCK2;
  }();
  var PATCH = /* @__PURE__ */ function() {
    function PATCH2() {
    }
    ;
    PATCH2.value = new PATCH2();
    return PATCH2;
  }();
  var showMethod = {
    show: function(v) {
      if (v instanceof OPTIONS) {
        return "OPTIONS";
      }
      ;
      if (v instanceof GET) {
        return "GET";
      }
      ;
      if (v instanceof HEAD) {
        return "HEAD";
      }
      ;
      if (v instanceof POST) {
        return "POST";
      }
      ;
      if (v instanceof PUT) {
        return "PUT";
      }
      ;
      if (v instanceof DELETE) {
        return "DELETE";
      }
      ;
      if (v instanceof TRACE) {
        return "TRACE";
      }
      ;
      if (v instanceof CONNECT) {
        return "CONNECT";
      }
      ;
      if (v instanceof PROPFIND) {
        return "PROPFIND";
      }
      ;
      if (v instanceof PROPPATCH) {
        return "PROPPATCH";
      }
      ;
      if (v instanceof MKCOL) {
        return "MKCOL";
      }
      ;
      if (v instanceof COPY) {
        return "COPY";
      }
      ;
      if (v instanceof MOVE) {
        return "MOVE";
      }
      ;
      if (v instanceof LOCK) {
        return "LOCK";
      }
      ;
      if (v instanceof UNLOCK) {
        return "UNLOCK";
      }
      ;
      if (v instanceof PATCH) {
        return "PATCH";
      }
      ;
      throw new Error("Failed pattern match at Data.HTTP.Method (line 43, column 1 - line 59, column 23): " + [v.constructor.name]);
    }
  };

  // output/Yoga.JSON/foreign.js
  function reviver(key2, value12) {
    if (key2 === "big") {
      return BigInt(value12);
    }
    return value12;
  }
  var _parseJSON2 = (payload) => JSON.parse(payload, reviver);
  function replacer(key2, value12) {
    if (typeof value12 === "bigint") {
      return value12.toString();
    }
    return value12;
  }
  var _unsafeStringify2 = (data) => JSON.stringify(data, replacer);

  // output/Yoga.JSON/index.js
  var identity9 = /* @__PURE__ */ identity(categoryBuilder);
  var readString3 = /* @__PURE__ */ readString(monadIdentity);
  var bindExceptT2 = /* @__PURE__ */ bindExceptT(monadIdentity);
  var pure8 = /* @__PURE__ */ pure(applicativeNonEmptyList);
  var except2 = /* @__PURE__ */ except(applicativeIdentity);
  var applicativeExceptT2 = /* @__PURE__ */ applicativeExceptT(monadIdentity);
  var pure12 = /* @__PURE__ */ pure(applicativeExceptT2);
  var map16 = /* @__PURE__ */ map(functorArray);
  var unwrap3 = /* @__PURE__ */ unwrap();
  var compose1 = /* @__PURE__ */ compose(semigroupoidBuilder);
  var insert6 = /* @__PURE__ */ insert4()();
  var append5 = /* @__PURE__ */ append(semigroupNonEmptyList);
  var functorExceptT2 = /* @__PURE__ */ functorExceptT(functorIdentity);
  var map1 = /* @__PURE__ */ map(functorExceptT2);
  var map22 = /* @__PURE__ */ map(functorNonEmptyList);
  var bindFlipped3 = /* @__PURE__ */ bindFlipped(bindExceptT2);
  var lmap3 = /* @__PURE__ */ lmap(bifunctorEither);
  var composeKleisliFlipped2 = /* @__PURE__ */ composeKleisliFlipped(bindExceptT2);
  var readProp2 = /* @__PURE__ */ readProp(monadIdentity);
  var mapWithIndex3 = /* @__PURE__ */ mapWithIndex(functorWithIndexArray);
  var readArray2 = /* @__PURE__ */ readArray(monadIdentity);
  var writeForeignString2 = {
    writeImpl: unsafeToForeign
  };
  var writeForeignNumber = {
    writeImpl: unsafeToForeign
  };
  var writeForeignInt = {
    writeImpl: unsafeToForeign
  };
  var writeForeignFieldsNilRowR = {
    writeImplFields: function(v) {
      return function(v1) {
        return identity9;
      };
    }
  };
  var writeForeignBoolean = {
    writeImpl: unsafeToForeign
  };
  var readForeignString = {
    readImpl: readString3
  };
  var readForeignFieldsNilRowRo = {
    getFields: function(v) {
      return function(v1) {
        return pure12(identity9);
      };
    }
  };
  var writeImplFields = function(dict) {
    return dict.writeImplFields;
  };
  var writeForeignRecord = function() {
    return function(dictWriteForeignFields) {
      var writeImplFields1 = writeImplFields(dictWriteForeignFields);
      return {
        writeImpl: function(rec) {
          var steps = writeImplFields1($$Proxy.value)(rec);
          return unsafeToForeign(build(steps)({}));
        }
      };
    };
  };
  var writeImpl2 = function(dict) {
    return dict.writeImpl;
  };
  var writeImpl1 = /* @__PURE__ */ writeImpl2(writeForeignNumber);
  var writeJSON = function(dictWriteForeign) {
    var $481 = writeImpl2(dictWriteForeign);
    return function($482) {
      return _unsafeStringify2($481($482));
    };
  };
  var writeForeignArray = function(dictWriteForeign) {
    var writeImpl5 = writeImpl2(dictWriteForeign);
    return {
      writeImpl: function(xs) {
        return unsafeToForeign(map16(writeImpl5)(xs));
      }
    };
  };
  var writeForeignFieldsCons = function(dictIsSymbol) {
    var get3 = get(dictIsSymbol)();
    var insert42 = insert6(dictIsSymbol);
    return function(dictWriteForeign) {
      var writeImpl5 = writeImpl2(dictWriteForeign);
      return function(dictWriteForeignFields) {
        var writeImplFields1 = writeImplFields(dictWriteForeignFields);
        return function() {
          return function() {
            return function() {
              return {
                writeImplFields: function(v) {
                  return function(rec) {
                    var rest = writeImplFields1($$Proxy.value)(rec);
                    var value12 = writeImpl5(get3($$Proxy.value)(rec));
                    var result = compose1(insert42($$Proxy.value)(value12))(rest);
                    return result;
                  };
                }
              };
            };
          };
        };
      };
    };
  };
  var writeForeignMilliseconds = {
    writeImpl: function($493) {
      return writeImpl1(unwrap3($493));
    }
  };
  var sequenceCombining = function(dictMonoid) {
    var append22 = append(dictMonoid.Semigroup0());
    var mempty3 = mempty(dictMonoid);
    return function(dictFoldable) {
      var foldl5 = foldl(dictFoldable);
      return function(dictApplicative) {
        var pure24 = pure(dictApplicative);
        var fn = function(acc) {
          return function(elem3) {
            var v = runExcept(elem3);
            if (acc instanceof Left && v instanceof Left) {
              return new Left(append5(acc.value0)(v.value0));
            }
            ;
            if (acc instanceof Left && v instanceof Right) {
              return new Left(acc.value0);
            }
            ;
            if (acc instanceof Right && v instanceof Right) {
              return new Right(append22(acc.value0)(pure24(v.value0)));
            }
            ;
            if (acc instanceof Right && v instanceof Left) {
              return new Left(v.value0);
            }
            ;
            throw new Error("Failed pattern match at Yoga.JSON (line 662, column 5 - line 666, column 37): " + [acc.constructor.name, v.constructor.name]);
          };
        };
        var $517 = foldl5(fn)(new Right(mempty3));
        return function($518) {
          return except2($517($518));
        };
      };
    };
  };
  var sequenceCombining1 = /* @__PURE__ */ sequenceCombining(monoidArray)(foldableArray)(applicativeArray);
  var readImpl2 = function(dict) {
    return dict.readImpl;
  };
  var readAtIdx = function(dictReadForeign) {
    var readImpl5 = readImpl2(dictReadForeign);
    return function(i) {
      return function(f) {
        return withExcept(map22(ErrorAtIndex.create(i)))(readImpl5(f));
      };
    };
  };
  var readForeignArray = function(dictReadForeign) {
    return {
      readImpl: composeKleisliFlipped2(function() {
        var $554 = mapWithIndex3(readAtIdx(dictReadForeign));
        return function($555) {
          return sequenceCombining1($554($555));
        };
      }())(readArray2)
    };
  };
  var parseJSON = /* @__PURE__ */ function() {
    var $560 = lmap3(function($563) {
      return pure8(ForeignError.create(message($563)));
    });
    var $561 = runEffectFn1(_parseJSON2);
    return function($562) {
      return ExceptT(Identity($560(unsafePerformEffect($$try($561($562))))));
    };
  }();
  var readJSON = function(dictReadForeign) {
    var $564 = composeKleisliFlipped2(readImpl2(dictReadForeign))(parseJSON);
    return function($565) {
      return runExcept($564($565));
    };
  };
  var getFields = function(dict) {
    return dict.getFields;
  };
  var readForeignFieldsCons = function(dictIsSymbol) {
    var reflectSymbol2 = reflectSymbol(dictIsSymbol);
    var insert42 = insert6(dictIsSymbol);
    return function(dictReadForeign) {
      var readImpl5 = readImpl2(dictReadForeign);
      return function(dictReadForeignFields) {
        var getFields1 = getFields(dictReadForeignFields);
        return function() {
          return function() {
            return {
              getFields: function(v) {
                return function(obj) {
                  var rest = getFields1($$Proxy.value)(obj);
                  var name15 = reflectSymbol2($$Proxy.value);
                  var enrichErrorWithPropName = withExcept(map22(ErrorAtProperty.create(name15)));
                  var value12 = enrichErrorWithPropName(bindFlipped3(readImpl5)(readProp2(name15)(obj)));
                  var first = map1(insert42($$Proxy.value))(value12);
                  return except2(function() {
                    var v1 = runExcept(rest);
                    var v2 = runExcept(first);
                    if (v2 instanceof Right && v1 instanceof Right) {
                      return new Right(compose1(v2.value0)(v1.value0));
                    }
                    ;
                    if (v2 instanceof Left && v1 instanceof Left) {
                      return new Left(append5(v2.value0)(v1.value0));
                    }
                    ;
                    if (v2 instanceof Right && v1 instanceof Left) {
                      return new Left(v1.value0);
                    }
                    ;
                    if (v2 instanceof Left && v1 instanceof Right) {
                      return new Left(v2.value0);
                    }
                    ;
                    throw new Error("Failed pattern match at Yoga.JSON (line 362, column 5 - line 366, column 33): " + [v2.constructor.name, v1.constructor.name]);
                  }());
                };
              }
            };
          };
        };
      };
    };
  };
  var readForeignRecord = function() {
    return function(dictReadForeignFields) {
      var getFields1 = getFields(dictReadForeignFields);
      return {
        readImpl: function(o) {
          return map1(flip(build)({}))(getFields1($$Proxy.value)(o));
        }
      };
    };
  };

  // output/Endpoints.ResponseParser/index.js
  var pure9 = /* @__PURE__ */ pure(applicativeEffect);
  var bind4 = /* @__PURE__ */ bind(bindAff);
  var liftEffect4 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var show8 = /* @__PURE__ */ show(showInt);
  var show13 = /* @__PURE__ */ show(/* @__PURE__ */ showNonEmptyList(showForeignError));
  var pure13 = /* @__PURE__ */ pure(applicativeAff);
  var validateResponse = function(response) {
    if (response.ok) {
      return pure9(response);
    }
    ;
    return throwMinsiError(new ErrorResponse(response.status));
  };
  var decodeJsonResponse = function(dictReadForeign) {
    var readJSON2 = readJSON(dictReadForeign);
    return function(context) {
      return function(response) {
        return bind4(response.text)(function(bodyText) {
          var $13 = bodyText === "";
          if ($13) {
            return liftEffect4(throwMinsiError(new JSONParsingError(context + (": empty response body" + (" (http " + (show8(response.status) + (" " + (response.statusText + ")"))))))));
          }
          ;
          var v = readJSON2(bodyText);
          if (v instanceof Left) {
            return liftEffect4(throwMinsiError(new JSONParsingError(context + (": " + (show13(v.value0) + (" (http " + (show8(response.status) + (" " + (response.statusText + (")" + (" body=" + bodyText)))))))))));
          }
          ;
          if (v instanceof Right) {
            return pure13(v.value0);
          }
          ;
          throw new Error("Failed pattern match at Endpoints.ResponseParser (line 33, column 5 - line 49, column 21): " + [v.constructor.name]);
        });
      };
    };
  };

  // output/Data.String.CaseInsensitive/index.js
  var compare2 = /* @__PURE__ */ compare(ordString);
  var CaseInsensitiveString = function(x) {
    return x;
  };
  var eqCaseInsensitiveString = {
    eq: function(v) {
      return function(v1) {
        return toLower(v) === toLower(v1);
      };
    }
  };
  var ordCaseInsensitiveString = {
    compare: function(v) {
      return function(v1) {
        return compare2(toLower(v))(toLower(v1));
      };
    },
    Eq0: function() {
      return eqCaseInsensitiveString;
    }
  };

  // output/JS.Fetch.Headers/foreign.js
  function unsafeFromRecord(r) {
    return new Headers(r);
  }
  function _toArray(tuple, headers2) {
    return Array.from(headers2.entries(), function(pair) {
      return tuple(pair[0])(pair[1]);
    });
  }

  // output/JS.Fetch.Headers/index.js
  var toArray3 = /* @__PURE__ */ function() {
    return runFn2(_toArray)(Tuple.create);
  }();
  var fromRecord = function() {
    return unsafeFromRecord;
  };

  // output/Fetch.Internal.Headers/index.js
  var toHeaders = /* @__PURE__ */ function() {
    var $7 = fromFoldable(ordCaseInsensitiveString)(foldableArray);
    var $8 = map(functorArray)(lmap(bifunctorTuple)(CaseInsensitiveString));
    return function($9) {
      return $7($8(toArray3($9)));
    };
  }();

  // output/JS.Fetch.RequestBody/foreign.js
  function fromString5(a) {
    return a;
  }

  // output/Fetch.Internal.RequestBody/index.js
  var toRequestBodyString = {
    toRequestBody: fromString5
  };
  var toRequestBody = function(dict) {
    return dict.toRequestBody;
  };

  // output/JS.Fetch.Request/foreign.js
  function _unsafeNew(url3, options2) {
    try {
      return new Request(url3, options2);
    } catch (e) {
      console.error(e);
      throw e;
    }
  }

  // output/Fetch.Internal.Request/index.js
  var fromRecord2 = /* @__PURE__ */ fromRecord();
  var show9 = /* @__PURE__ */ show(showMethod);
  var toCoreRequestOptionsHelpe = {
    convertHelper: function(v) {
      return function(v1) {
        return {};
      };
    }
  };
  var toCoreRequestOptionsConve7 = function(dictToRequestBody) {
    var toRequestBody2 = toRequestBody(dictToRequestBody);
    return {
      convertImpl: function(v) {
        return toRequestBody2;
      }
    };
  };
  var toCoreRequestOptionsConve8 = function() {
    return {
      convertImpl: function(v) {
        return fromRecord2;
      }
    };
  };
  var toCoreRequestOptionsConve9 = {
    convertImpl: function(v) {
      return show9;
    }
  };
  var $$new2 = function() {
    return function(url3) {
      return function(options2) {
        return function() {
          return _unsafeNew(url3, options2);
        };
      };
    };
  };
  var convertImpl = function(dict) {
    return dict.convertImpl;
  };
  var convertHelper = function(dict) {
    return dict.convertHelper;
  };
  var toCoreRequestOptionsHelpe1 = function(dictToCoreRequestOptionsConverter) {
    var convertImpl1 = convertImpl(dictToCoreRequestOptionsConverter);
    return function() {
      return function() {
        return function() {
          return function(dictIsSymbol) {
            var $$delete4 = $$delete2(dictIsSymbol)()();
            var get3 = get(dictIsSymbol)();
            var insert7 = insert3(dictIsSymbol)()();
            return function(dictToCoreRequestOptionsHelper) {
              var convertHelper1 = convertHelper(dictToCoreRequestOptionsHelper);
              return function() {
                return function() {
                  return {
                    convertHelper: function(v) {
                      return function(r) {
                        var tail3 = convertHelper1($$Proxy.value)($$delete4($$Proxy.value)(r));
                        var head3 = convertImpl1($$Proxy.value)(get3($$Proxy.value)(r));
                        return insert7($$Proxy.value)(head3)(tail3);
                      };
                    }
                  };
                };
              };
            };
          };
        };
      };
    };
  };
  var toCoreRequestOptionsRowRo = function() {
    return function() {
      return function(dictToCoreRequestOptionsHelper) {
        return {
          convert: convertHelper(dictToCoreRequestOptionsHelper)($$Proxy.value)
        };
      };
    };
  };
  var convert = function(dict) {
    return dict.convert;
  };

  // output/JS.Fetch.Response/foreign.js
  function headers(resp) {
    return resp.headers;
  }
  function ok(resp) {
    return resp.ok;
  }
  function redirected(resp) {
    return resp.redirected;
  }
  function status(resp) {
    return resp.status;
  }
  function statusText(resp) {
    return resp.statusText;
  }
  function url2(resp) {
    return resp.url;
  }
  function body(resp) {
    return function() {
      return resp.body;
    };
  }
  function arrayBuffer(resp) {
    return function() {
      return resp.arrayBuffer();
    };
  }
  function blob(resp) {
    return function() {
      return resp.blob();
    };
  }
  function text5(resp) {
    return function() {
      return resp.text();
    };
  }
  function json(resp) {
    return function() {
      return resp.json();
    };
  }

  // output/Promise.Internal/foreign.js
  function thenOrCatch(k, c, p) {
    return p.then(k, c);
  }
  function resolve(a) {
    return Promise.resolve(a);
  }

  // output/Promise.Rejection/foreign.js
  function _toError(just, nothing, ref) {
    if (ref instanceof Error) {
      return just(ref);
    }
    return nothing;
  }

  // output/Promise.Rejection/index.js
  var toError = /* @__PURE__ */ function() {
    return runFn3(_toError)(Just.create)(Nothing.value);
  }();

  // output/Promise/index.js
  var thenOrCatch2 = function() {
    return function(k) {
      return function(c) {
        return function(p) {
          return function() {
            return thenOrCatch(mkEffectFn1(k), mkEffectFn1(c), p);
          };
        };
      };
    };
  };
  var resolve2 = function() {
    return resolve;
  };

  // output/Promise.Aff/index.js
  var voidRight2 = /* @__PURE__ */ voidRight(functorEffect);
  var mempty2 = /* @__PURE__ */ mempty(monoidCanceler);
  var thenOrCatch3 = /* @__PURE__ */ thenOrCatch2();
  var map17 = /* @__PURE__ */ map(functorEffect);
  var resolve3 = /* @__PURE__ */ resolve2();
  var alt6 = /* @__PURE__ */ alt(altMaybe);
  var map18 = /* @__PURE__ */ map(functorMaybe);
  var readString4 = /* @__PURE__ */ readString(monadIdentity);
  var bind5 = /* @__PURE__ */ bind(bindAff);
  var liftEffect5 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var toAff$prime = function(customCoerce) {
    return function(p) {
      return makeAff(function(cb) {
        return voidRight2(mempty2)(thenOrCatch3(function(a) {
          return map17(resolve3)(cb(new Right(a)));
        })(function(e) {
          return map17(resolve3)(cb(new Left(customCoerce(e))));
        })(p));
      });
    };
  };
  var coerce3 = function(rej) {
    return fromMaybe$prime(function(v) {
      return error("Promise failed, couldn't extract JS Error or String");
    })(alt6(toError(rej))(map18(error)(hush(runExcept(readString4(unsafeToForeign(rej)))))));
  };
  var toAff = /* @__PURE__ */ toAff$prime(coerce3);
  var toAffE = function(f) {
    return bind5(liftEffect5(f))(toAff);
  };

  // output/Fetch.Internal.Response/index.js
  var text6 = function(response) {
    return toAffE(text5(response));
  };
  var json2 = function(response) {
    return toAffE(json(response));
  };
  var blob2 = function(response) {
    return toAffE(blob(response));
  };
  var arrayBuffer2 = function(response) {
    return toAffE(arrayBuffer(response));
  };
  var convert2 = function(response) {
    return {
      headers: toHeaders(headers(response)),
      ok: ok(response),
      redirected: redirected(response),
      status: status(response),
      statusText: statusText(response),
      url: url2(response),
      text: text6(response),
      json: json2(response),
      body: body(response),
      arrayBuffer: arrayBuffer2(response),
      blob: blob2(response)
    };
  };

  // output/JS.Fetch/foreign.js
  function _fetch(a, b) {
    return fetch(a, b);
  }

  // output/JS.Fetch/index.js
  var fetchWithOptions = function() {
    return runEffectFn2(_fetch);
  };

  // output/JS.Fetch.AbortController/foreign.js
  var newImpl3 = function() {
    return new AbortController();
  };
  function abort(controller) {
    return function() {
      return controller.abort();
    };
  }
  function signal(controller) {
    return controller.signal;
  }

  // output/Fetch/index.js
  var $$void6 = /* @__PURE__ */ $$void(functorEffect);
  var thenOrCatch4 = /* @__PURE__ */ thenOrCatch2();
  var map19 = /* @__PURE__ */ map(functorEffect);
  var resolve4 = /* @__PURE__ */ resolve2();
  var bind6 = /* @__PURE__ */ bind(bindAff);
  var liftEffect6 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var $$new4 = /* @__PURE__ */ $$new2();
  var bindFlipped4 = /* @__PURE__ */ bindFlipped(bindAff);
  var fetchWithOptions2 = /* @__PURE__ */ fetchWithOptions();
  var pure14 = /* @__PURE__ */ pure(applicativeAff);
  var toAbortableAff = function(abortController) {
    return function(p) {
      return makeAff(function(cb) {
        return function __do5() {
          $$void6(thenOrCatch4(function(a) {
            return map19(resolve4)(cb(new Right(a)));
          })(function(e) {
            return map19(resolve4)(cb(new Left(coerce3(e))));
          })(p))();
          return effectCanceler(abort(abortController));
        };
      });
    };
  };
  var fetch2 = function() {
    return function() {
      return function(dictToCoreRequestOptions) {
        var convert3 = convert(dictToCoreRequestOptions);
        return function(url3) {
          return function(r) {
            return bind6(liftEffect6($$new4(url3)(convert3(r))))(function(request) {
              return bind6(liftEffect6(newImpl3))(function(abortController) {
                var signal2 = signal(abortController);
                return bind6(bindFlipped4(toAbortableAff(abortController))(liftEffect6(fetchWithOptions2(request)({
                  signal: signal2
                }))))(function(cResponse) {
                  return pure14(convert2(cResponse));
                });
              });
            });
          };
        };
      };
    };
  };

  // output/Main.Config/index.js
  var backendUrl = "http://localhost:8080/";

  // output/Model.State.State/index.js
  var writeImpl3 = /* @__PURE__ */ writeImpl2(writeForeignString2);
  var writeForeignRecord2 = /* @__PURE__ */ writeForeignRecord();
  var Top = /* @__PURE__ */ function() {
    function Top2() {
    }
    ;
    Top2.value = new Top2();
    return Top2;
  }();
  var Bottom = /* @__PURE__ */ function() {
    function Bottom2() {
    }
    ;
    Bottom2.value = new Bottom2();
    return Bottom2;
  }();
  var Impact = /* @__PURE__ */ function() {
    function Impact2() {
    }
    ;
    Impact2.value = new Impact2();
    return Impact2;
  }();
  var ArialBlack = /* @__PURE__ */ function() {
    function ArialBlack2() {
    }
    ;
    ArialBlack2.value = new ArialBlack2();
    return ArialBlack2;
  }();
  var White = /* @__PURE__ */ function() {
    function White2() {
    }
    ;
    White2.value = new White2();
    return White2;
  }();
  var Black = /* @__PURE__ */ function() {
    function Black2() {
    }
    ;
    Black2.value = new Black2();
    return Black2;
  }();
  var LightGreen = /* @__PURE__ */ function() {
    function LightGreen2() {
    }
    ;
    LightGreen2.value = new LightGreen2();
    return LightGreen2;
  }();
  var LightOrange = /* @__PURE__ */ function() {
    function LightOrange2() {
    }
    ;
    LightOrange2.value = new LightOrange2();
    return LightOrange2;
  }();
  var Yellow = /* @__PURE__ */ function() {
    function Yellow2() {
    }
    ;
    Yellow2.value = new Yellow2();
    return Yellow2;
  }();
  var writeForeignWURL = {
    writeImpl: function(v) {
      return writeImpl3(toString(v));
    }
  };
  var writeForeignPosition = {
    writeImpl: function(v) {
      if (v instanceof Top) {
        return writeImpl3("Top");
      }
      ;
      if (v instanceof Bottom) {
        return writeImpl3("Bottom");
      }
      ;
      throw new Error("Failed pattern match at Model.State.State (line 64, column 1 - line 66, column 40): " + [v.constructor.name]);
    }
  };
  var writeForeignFont = {
    writeImpl: function(v) {
      if (v instanceof Impact) {
        return writeImpl3("Impact");
      }
      ;
      if (v instanceof ArialBlack) {
        return writeImpl3("Arial Black");
      }
      ;
      throw new Error("Failed pattern match at Model.State.State (line 75, column 1 - line 77, column 49): " + [v.constructor.name]);
    }
  };
  var writeForeignColor = {
    writeImpl: function(v) {
      if (v instanceof White) {
        return writeImpl3("#ffffff");
      }
      ;
      if (v instanceof Black) {
        return writeImpl3("#000000");
      }
      ;
      if (v instanceof LightGreen) {
        return writeImpl3("#ABEBC6");
      }
      ;
      if (v instanceof LightOrange) {
        return writeImpl3("#FAD7A0");
      }
      ;
      if (v instanceof Yellow) {
        return writeImpl3("#FFFF00");
      }
      ;
      throw new Error("Failed pattern match at Model.State.State (line 68, column 1 - line 73, column 41): " + [v.constructor.name]);
    }
  };
  var writeDurationRange = /* @__PURE__ */ writeForeignRecord2(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "end";
    }
  })(writeForeignMilliseconds)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "start";
    }
  })(writeForeignMilliseconds)(writeForeignFieldsNilRowR)()()())()()());
  var writeSubtitle = /* @__PURE__ */ writeForeignRecord2(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "color";
    }
  })(writeForeignColor)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "font";
    }
  })(writeForeignFont)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "fontSize";
    }
  })(writeForeignInt)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "screenPosition";
    }
  })(writeForeignPosition)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "value";
    }
  })(writeForeignString2)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "videoPosition";
    }
  })(writeDurationRange)(writeForeignFieldsNilRowR)()()())()()())()()())()()())()()())()()());
  var writeState = /* @__PURE__ */ writeForeignRecord2(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "artist";
    }
  })(writeForeignString2)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "cutVideo";
    }
  })(writeDurationRange)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "filename";
    }
  })(writeForeignString2)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "reverseLoop";
    }
  })(writeForeignBoolean)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "subtitles";
    }
  })(/* @__PURE__ */ writeForeignArray(writeSubtitle))(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "title";
    }
  })(writeForeignString2)(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "youtubeUrl";
    }
  })(writeForeignWURL)(writeForeignFieldsNilRowR)()()())()()())()()())()()())()()())()()())()()());

  // output/Endpoints.Compute/index.js
  var bind7 = /* @__PURE__ */ bind(bindAff);
  var fetch3 = /* @__PURE__ */ fetch2()()(/* @__PURE__ */ toCoreRequestOptionsRowRo()()(/* @__PURE__ */ toCoreRequestOptionsHelpe1(/* @__PURE__ */ toCoreRequestOptionsConve7(toRequestBodyString))()()()({
    reflectSymbol: function() {
      return "body";
    }
  })(/* @__PURE__ */ toCoreRequestOptionsHelpe1(/* @__PURE__ */ toCoreRequestOptionsConve8())()()()({
    reflectSymbol: function() {
      return "headers";
    }
  })(/* @__PURE__ */ toCoreRequestOptionsHelpe1(toCoreRequestOptionsConve9)()()()({
    reflectSymbol: function() {
      return "method";
    }
  })(toCoreRequestOptionsHelpe)()())()())()()));
  var writeJSON2 = /* @__PURE__ */ writeJSON(writeState);
  var liftEffect7 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var computeEndpoint = /* @__PURE__ */ function() {
    return backendUrl + "compute";
  }();
  var callCompute = function(state3) {
    return bind7(fetch3(computeEndpoint)({
      method: POST.value,
      body: writeJSON2(state3),
      headers: {
        "Content-Type": "application/json"
      }
    }))(function(response) {
      return liftEffect7(validateResponse(response));
    });
  };

  // output/Model.ProcessStatus/index.js
  var bind8 = /* @__PURE__ */ bind(/* @__PURE__ */ bindExceptT(monadIdentity));
  var readImpl3 = /* @__PURE__ */ readImpl2(readForeignString);
  var pure10 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeExceptT(monadIdentity));
  var fail2 = /* @__PURE__ */ fail(monadIdentity);
  var Pending = /* @__PURE__ */ function() {
    function Pending2() {
    }
    ;
    Pending2.value = new Pending2();
    return Pending2;
  }();
  var Succeed = /* @__PURE__ */ function() {
    function Succeed2() {
    }
    ;
    Succeed2.value = new Succeed2();
    return Succeed2;
  }();
  var Failed = /* @__PURE__ */ function() {
    function Failed2() {
    }
    ;
    Failed2.value = new Failed2();
    return Failed2;
  }();
  var readForeignProcessStatus = {
    readImpl: function(f) {
      return bind8(readImpl3(f))(function(s) {
        if (s === "Pending") {
          return pure10(Pending.value);
        }
        ;
        if (s === "Succeed") {
          return pure10(Succeed.value);
        }
        ;
        if (s === "Failed") {
          return pure10(Failed.value);
        }
        ;
        return fail2(new TypeMismatch("ProcessStatus", "Invalid ProcessStatus: " + s));
      });
    }
  };

  // output/Endpoints.Status/index.js
  var bind9 = /* @__PURE__ */ bind(bindAff);
  var fetch4 = /* @__PURE__ */ fetch2()()(/* @__PURE__ */ toCoreRequestOptionsRowRo()()(/* @__PURE__ */ toCoreRequestOptionsHelpe1(/* @__PURE__ */ toCoreRequestOptionsConve7(toRequestBodyString))()()()({
    reflectSymbol: function() {
      return "body";
    }
  })(/* @__PURE__ */ toCoreRequestOptionsHelpe1(/* @__PURE__ */ toCoreRequestOptionsConve8())()()()({
    reflectSymbol: function() {
      return "headers";
    }
  })(/* @__PURE__ */ toCoreRequestOptionsHelpe1(toCoreRequestOptionsConve9)()()()({
    reflectSymbol: function() {
      return "method";
    }
  })(toCoreRequestOptionsHelpe)()())()())()()));
  var writeJSON3 = /* @__PURE__ */ writeJSON(/* @__PURE__ */ writeForeignRecord()(/* @__PURE__ */ writeForeignFieldsCons({
    reflectSymbol: function() {
      return "filename";
    }
  })(writeForeignString2)(writeForeignFieldsNilRowR)()()()));
  var decodeJsonResponse2 = /* @__PURE__ */ decodeJsonResponse(/* @__PURE__ */ readForeignRecord()(/* @__PURE__ */ readForeignFieldsCons({
    reflectSymbol: function() {
      return "status";
    }
  })(readForeignProcessStatus)(readForeignFieldsNilRowRo)()()));
  var statusEndpoint = /* @__PURE__ */ function() {
    return backendUrl + "status";
  }();
  var callStatus = function(filename) {
    return bind9(fetch4(statusEndpoint)({
      method: POST.value,
      body: writeJSON3({
        filename
      }),
      headers: {
        "Content-Type": "application/json"
      }
    }))(function(response) {
      return decodeJsonResponse2("status")(response);
    });
  };

  // output/Conversion.String/index.js
  var capitalize = /* @__PURE__ */ function() {
    var $2 = joinWith(" ");
    var $3 = map(functorArray)(function() {
      var $6 = fromMaybe([]);
      var $7 = modifyAt(0)(function($9) {
        return char(toUpper(singleton5($9)));
      });
      return function($8) {
        return fromCharArray($6($7(toCharArray($8))));
      };
    }());
    var $4 = split(" ");
    return function($5) {
      return $2($3($4($5)));
    };
  }();

  // output/Parse.Font/index.js
  var parsePosition = function(v) {
    if (v === "Top") {
      return Top.value;
    }
    ;
    return Bottom.value;
  };
  var parseFont = function(v) {
    if (v === "Arial Black") {
      return ArialBlack.value;
    }
    ;
    return Impact.value;
  };
  var parseColor = function(v) {
    if (v === "Black") {
      return Black.value;
    }
    ;
    if (v === "Light Green") {
      return LightGreen.value;
    }
    ;
    if (v === "Light Orange") {
      return LightOrange.value;
    }
    ;
    if (v === "Yellow") {
      return Yellow.value;
    }
    ;
    return White.value;
  };

  // output/Validations.CutVideoValidation/index.js
  var show10 = /* @__PURE__ */ show(showNumber);
  var pure11 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeV(semigroupValidationErrors));
  var cutVideoValidation = function(id2) {
    return function(start2) {
      return function(end) {
        var $6 = start2 >= end - 100;
        if ($6) {
          return invalid(fromSingleton(id2)("start >= end - 100: " + (show10(start2) + (" " + show10(end)))));
        }
        ;
        return pure11({
          start: start2,
          end
        });
      };
    };
  };

  // output/Validations.NonEmptyValidation/index.js
  var lmap4 = /* @__PURE__ */ lmap(bifunctorEither);
  var lmap12 = /* @__PURE__ */ lmap(bifunctorV);
  var nonEmptyRegex = "[\\S\\s]*\\S[\\S\\s]*";
  var nonEmptyRegexValidation = function(id2) {
    return lmap4(function(x) {
      return fromSingleton(id2)(x);
    })(regex(nonEmptyRegex)(noFlags));
  };
  var nonEmptyValidation = function(id2) {
    return function(v) {
      return lmap12(function(v1) {
        return fromSingleton(id2)("value cannot be empty");
      })(andThen(nonEmptyRegexValidation(id2))(function(r) {
        return matches2(r)(id2)(v);
      }));
    };
  };

  // output/Model.State.StateFromHtml/index.js
  var bind10 = /* @__PURE__ */ bind(bindEffect);
  var pure15 = /* @__PURE__ */ pure(applicativeEffect);
  var mapFlipped2 = /* @__PURE__ */ mapFlipped(functorEffect);
  var bind15 = /* @__PURE__ */ bind(bindMaybe);
  var identity10 = /* @__PURE__ */ identity(categoryFn);
  var map20 = /* @__PURE__ */ map(functorEffect);
  var traverse4 = /* @__PURE__ */ traverse(traversableArray)(applicativeEffect);
  var apply5 = /* @__PURE__ */ apply(/* @__PURE__ */ applyV(semigroupValidationErrors));
  var map110 = /* @__PURE__ */ map(functorV);
  var youtubeUrlFromHTMLInput = function(youtubeUrlComponent) {
    return function __do5() {
      var urlString = value2(youtubeUrlComponent)();
      return youtubeUrlValidation(youtubeUrlId)(urlString);
    };
  };
  var nonEmptyFromHtmlInput = function(i) {
    return function(id2) {
      return mapFlipped2(value2(i))(nonEmptyValidation(id2));
    };
  };
  var getTextAreaValueFromCell = function(cell) {
    var element = toElement6(cell);
    var parentNode2 = toParentNode(element);
    return function __do5() {
      var elementMaybe = querySelector("textarea")(parentNode2)();
      var textareaMaybe = bind15(elementMaybe)(fromElement14);
      if (textareaMaybe instanceof Nothing) {
        return "";
      }
      ;
      if (textareaMaybe instanceof Just) {
        return value11(textareaMaybe.value0)();
      }
      ;
      throw new Error("Failed pattern match at Model.State.StateFromHtml (line 135, column 3 - line 137, column 40): " + [textareaMaybe.constructor.name]);
    };
  };
  var getSelectValueFromCell = function(cell) {
    var element = toElement6(cell);
    var parentNode2 = toParentNode(element);
    return function __do5() {
      var elementMaybe = querySelector("select")(parentNode2)();
      var selectMaybe = bind15(elementMaybe)(fromElement5);
      if (selectMaybe instanceof Nothing) {
        return "";
      }
      ;
      if (selectMaybe instanceof Just) {
        return value3(selectMaybe.value0)();
      }
      ;
      throw new Error("Failed pattern match at Model.State.StateFromHtml (line 145, column 3 - line 147, column 35): " + [selectMaybe.constructor.name]);
    };
  };
  var getInputValueFromCell = function(cell) {
    var element = toElement6(cell);
    var parentNode2 = toParentNode(element);
    return function __do5() {
      var elementMaybe = querySelector("input")(parentNode2)();
      var inputMaybe = bind15(elementMaybe)(fromElement4);
      if (inputMaybe instanceof Nothing) {
        return Nothing.value;
      }
      ;
      if (inputMaybe instanceof Just) {
        return mapFlipped2(valueAsNumber(inputMaybe.value0))(Just.create)();
      }
      ;
      throw new Error("Failed pattern match at Model.State.StateFromHtml (line 125, column 3 - line 127, column 47): " + [inputMaybe.constructor.name]);
    };
  };
  var loadSubtitleFromRow = function(row) {
    return function __do5() {
      var cells2 = cells(row)();
      var cellArray = toArray2(cells2)();
      if (cellArray.length === 8) {
        var startValue = function __do6() {
          var v = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableStartCell")))(pure15)(fromElement11(cellArray[0])))(getInputValueFromCell)();
          return maybe(0)(identity10)(v);
        }();
        var endValue = function __do6() {
          var v = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTableEndCell")))(pure15)(fromElement11(cellArray[1])))(getInputValueFromCell)();
          return maybe(0)(identity10)(v);
        }();
        var valueText = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTablevalueCell")))(pure15)(fromElement11(cellArray[2])))(getTextAreaValueFromCell)();
        var fontValue = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTablefontCell")))(pure15)(fromElement11(cellArray[3])))(getSelectValueFromCell)();
        var fontSizeValue = function __do6() {
          var v = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTablefontSizeCell")))(pure15)(fromElement11(cellArray[4])))(getInputValueFromCell)();
          return maybe(48)(floor2)(v);
        }();
        var colorValue = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTablecolorCell")))(pure15)(fromElement11(cellArray[5])))(getSelectValueFromCell)();
        var positionValue = bind10(maybe(throwMinsiError(new HTMLElementNotFound("SubtitleTablepositionCell")))(pure15)(fromElement11(cellArray[6])))(getSelectValueFromCell)();
        return new Just({
          videoPosition: {
            start: startValue,
            end: endValue
          },
          value: toUpper(trim(valueText)),
          font: parseFont(fontValue),
          fontSize: fontSizeValue,
          color: parseColor(colorValue),
          screenPosition: parsePosition(positionValue)
        });
      }
      ;
      return Nothing.value;
    };
  };
  var loadSubtitlesFromTable = function(table) {
    return function __do5() {
      var rows4 = getRows(table)();
      var subtitles = map20(catMaybes)(traverse4(loadSubtitleFromRow)(rows4))();
      return subtitles;
    };
  };
  var cutVideoFromHtmlRange = function(cutStart) {
    return function(cutEnd) {
      return function __do5() {
        var start2 = valueAsNumber(cutStart)();
        var end = valueAsNumber(cutEnd)();
        return cutVideoValidation(cutStartId)(start2)(end);
      };
    };
  };
  var fromHtmlInputs = function(v) {
    return function __do5() {
      var cutVideoV = cutVideoFromHtmlRange(v.value0.cutStart)(v.value0.cutEnd)();
      var youtubeUrlV = youtubeUrlFromHTMLInput(v.value0.youtubeUrl)();
      var filenameV = nonEmptyFromHtmlInput(v.value0.filename)(outputFilenameId)();
      var reverseLoopValue = checked(v.value0.reverseLoop)();
      var artistV = nonEmptyFromHtmlInput(v.value0.artist)(artistId)();
      var titleV = nonEmptyFromHtmlInput(v.value0.title)(titleId)();
      var subtitles = loadSubtitlesFromTable(v.value0.subtitleTable)();
      return apply5(apply5(apply5(apply5(map110(function(v1) {
        return function(v2) {
          return function(v3) {
            return function(v4) {
              return function(v5) {
                return {
                  cutVideo: v1,
                  youtubeUrl: v2,
                  filename: v3,
                  reverseLoop: reverseLoopValue,
                  artist: capitalize(v4),
                  title: capitalize(v5),
                  subtitles
                };
              };
            };
          };
        };
      })(cutVideoV))(youtubeUrlV))(filenameV))(artistV))(titleV);
    };
  };

  // output/Web.DOM.DOMTokenList/foreign.js
  function contains4(list) {
    return function(token) {
      return function() {
        return list.contains(token);
      };
    };
  }
  function remove(list) {
    return function(token) {
      return function() {
        return list.remove(token);
      };
    };
  }

  // output/Web.DOM.DocumentFragment/index.js
  var toParentNode2 = unsafeCoerce2;

  // output/Handlers.ApplyButtonHandler/index.js
  var bind11 = /* @__PURE__ */ bind(bindAff);
  var voidLeft2 = /* @__PURE__ */ voidLeft(functorAff);
  var pure16 = /* @__PURE__ */ pure(applicativeAff);
  var liftEffect8 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var tailRecM3 = /* @__PURE__ */ tailRecM(monadRecAff);
  var map21 = /* @__PURE__ */ map(functorEffect);
  var show11 = /* @__PURE__ */ show(showNumber);
  var when4 = /* @__PURE__ */ when(applicativeEffect);
  var pure17 = /* @__PURE__ */ pure(applicativeEffect);
  var bind22 = /* @__PURE__ */ bind(bindMaybe);
  var $$void7 = /* @__PURE__ */ $$void(functorEffect);
  var traverse5 = /* @__PURE__ */ traverse(traversableArray)(applicativeEffect);
  var unless2 = /* @__PURE__ */ unless(applicativeEffect);
  var unwrap4 = /* @__PURE__ */ unwrap();
  var applySecond3 = /* @__PURE__ */ applySecond(applyAff);
  var void1 = /* @__PURE__ */ $$void(functorAff);
  var waitForStatus = function(filename) {
    var pollStatus = function(v) {
      return bind11(callStatus(filename))(function(response) {
        if (response.status instanceof Pending) {
          return voidLeft2(delay(500))(new Loop(unit));
        }
        ;
        if (response.status instanceof Succeed) {
          return pure16(new Done(unit));
        }
        ;
        if (response.status instanceof Failed) {
          return liftEffect8(throwMinsiError(new ComputeFailed("Video download failed")));
        }
        ;
        throw new Error("Failed pattern match at Handlers.ApplyButtonHandler (line 93, column 5 - line 96, column 85): " + [response.status.constructor.name]);
      });
    };
    return tailRecM3(pollStatus)(unit);
  };
  var setVideoSrc = function(filepath) {
    return function(video) {
      var videoMediaElement = toHTMLMediaElement(video);
      return function __do5() {
        var v = map21(unInstant)(now)();
        var cacheBustedPath = filepath + ("?t=" + show11(v));
        pause(videoMediaElement)();
        setSrc5(cacheBustedPath)(videoMediaElement)();
        return load(videoMediaElement)();
      };
    };
  };
  var scrollToVideoSource = function __do2() {
    var w = windowImpl();
    var loc = location(w)();
    return setHash("#" + videoSourceId)(loc)();
  };
  var removeClass = function(className2) {
    return function(div2) {
      var element = toElement2(div2);
      return function __do5() {
        var classList2 = classList(element)();
        var containsClassName = contains4(classList2)(className2)();
        return when4(containsClassName)(remove(classList2)(className2))();
      };
    };
  };
  var getRow = function(subtitleTemplateElement) {
    return function __do5() {
      var fragment = content(subtitleTemplateElement)();
      var firstEl = firstElementChild(toParentNode2(fragment))();
      return maybe(throwMinsiError(new HTMLElementNotFound("subtitleRowTemplate")))(pure17)(bind22(firstEl)(fromElement12))();
    };
  };
  var setSubtitleTableMaxValues = function(v) {
    return function(subtitleTable) {
      return function(subtitleRowTemplate) {
        var durationSeconds = v.cutVideo.end - v.cutVideo.start;
        return function __do5() {
          var subtitleRow2 = getRow(subtitleRowTemplate)();
          var rows4 = getRows(subtitleTable)();
          $$void7(traverse5(function(row) {
            return function __do6() {
              var startInput = getStartInput(row)();
              var endInput = getEndInput(row)();
              setMax(show11(durationSeconds))(startInput)();
              return setMax(show11(durationSeconds))(endInput)();
            };
          })(cons(subtitleRow2)(rows4)))();
          return log("Set max values for all subtitle inputs to " + (show11(durationSeconds) + " millis"))();
        };
      };
    };
  };
  var getCurrentState = function __do3() {
    var doc = getDocument();
    var components = loadComponents(doc)();
    var stateV = fromHtmlInputs(components.htmlInputs)();
    var state3 = either(function($48) {
      return throwMinsiError(InvalidInputs.create(toMap($48)));
    })(pure17)(toEither(stateV))();
    return new Tuple(state3, components);
  };
  var addClass = function(className2) {
    return function(div2) {
      var element = toElement2(div2);
      return function __do5() {
        var classList2 = classList(element)();
        var containsClassName = contains4(classList2)(className2)();
        return unless2(containsClassName)(remove(classList2)(className2))();
      };
    };
  };
  var showHiddenElements = function(v) {
    return function(reverseLoop) {
      return function __do5() {
        removeClass("d-none")(v.value0.videoSourceRow)();
        removeClass("d-none")(v.value0.videoRow)();
        (function() {
          if (reverseLoop) {
            return addClass("d-none")(v.value0.subtitlesRow)();
          }
          ;
          return removeClass("d-none")(v.value0.subtitlesRow)();
        })();
        return removeClass("d-none")(v.value0.playbackPositionResultRow)();
      };
    };
  };
  var finallyHandlers = function(components) {
    return function(state3) {
      var reverseLoop = unwrap4(state3).reverseLoop;
      var filename = unwrap4(state3).filename;
      var filepath = mp4(filename);
      return function __do5() {
        log("return from server, show elements and set src")();
        showHiddenElements(components.htmlVisualElements)(reverseLoop)();
        log("hide modal, and scroll")();
        hideModal(loadingModalId)();
        scrollToVideoSource();
        var videoMediaElement = unwrap4(components.htmlOutputs).resultVideo;
        setVideoSrc(filepath)(videoMediaElement)();
        return setSubtitleTableMaxValues(state3)(components.htmlInputs.value0.subtitleTable)(components.htmlInputs.value0.subtitleRow)();
      };
    };
  };
  var applyButtonEventListener = function(v) {
    return function __do5() {
      var stateComponents = getCurrentState();
      var state3 = fst(stateComponents);
      var components = snd(stateComponents);
      var filename = unwrap4(state3).filename;
      showModal(loadingModalId)();
      return runAff_(function(result) {
        return genericErrorsHandlerEither(result);
      })($$finally(liftEffect8(finallyHandlers(components)(state3)))(applySecond3(void1(callCompute(state3)))(waitForStatus(filename))))();
    };
  };
  var setApplyButtonHandler = function(applyButton) {
    var applyButtonEventTarget = toEventTarget2(toElement(applyButton));
    return genericErrorsHandler(function __do5() {
      var applyButtonEvL = eventListener(applyButtonEventListener)();
      return addEventListener(click2)(applyButtonEvL)(false)(applyButtonEventTarget)();
    });
  };

  // output/Web.DOM.ElementName/index.js
  var eqElementName = eqString;

  // output/Handlers.RemoveSubtitleButtonHandler/index.js
  var bindMaybeT2 = /* @__PURE__ */ bindMaybeT(monadEffect);
  var bind16 = /* @__PURE__ */ bind(bindMaybeT2);
  var lift3 = /* @__PURE__ */ lift(monadTransMaybeT)(monadEffect);
  var bind17 = /* @__PURE__ */ bind(bindEffect);
  var applySecond4 = /* @__PURE__ */ applySecond(applyEffect);
  var pure18 = /* @__PURE__ */ pure(applicativeEffect);
  var map23 = /* @__PURE__ */ map(functorMaybe);
  var eq2 = /* @__PURE__ */ eq(eqElementName);
  var iterateUntilM2 = /* @__PURE__ */ iterateUntilM(/* @__PURE__ */ monadMaybeT(monadEffect));
  var bind23 = /* @__PURE__ */ bind(bindMaybe);
  var discard3 = /* @__PURE__ */ discard(discardUnit);
  var discard1 = /* @__PURE__ */ discard3(bindMaybeT2);
  var when5 = /* @__PURE__ */ when(/* @__PURE__ */ applicativeMaybeT(monadEffect));
  var traverse_2 = /* @__PURE__ */ traverse_(applicativeEffect)(foldableArray);
  var removeRowFromDom = function(tableRow) {
    var rowNode = toNode3(tableRow);
    return bind16(parentNode(rowNode))(function(parentNode$prime) {
      return lift3(removeChild(rowNode)(parentNode$prime));
    });
  };
  var removeFirstSubtitleRow = function(subtitleTable) {
    return function __do5() {
      var rows4 = getRows(subtitleTable)();
      var v = head(rows4);
      if (v instanceof Just) {
        return applySecond4(runMaybeT(removeRowFromDom(v.value0)))(pure18(unit))();
      }
      ;
      if (v instanceof Nothing) {
        return unit;
      }
      ;
      throw new Error("Failed pattern match at Handlers.RemoveSubtitleButtonHandler (line 82, column 3 - line 84, column 25): " + [v.constructor.name]);
    };
  };
  var isTrElement = function(node) {
    return fromMaybe(false)(map23(function($25) {
      return function(v) {
        return eq2(v)("TR");
      }(tagName($25));
    })(fromNode(node)));
  };
  var getParentNode = function(node) {
    return parentNode(node);
  };
  var findTrAncestor = function(node) {
    return bind16(iterateUntilM2(isTrElement)(getParentNode)(node))(function(trNode) {
      return pure18(bind23(fromNode(trNode))(fromElement12));
    });
  };
  var removeSubtitleButtonEventListenerTrans = function(ev) {
    return discard1(lift3(log("Remove subtitle button clicked")))(function() {
      return bind16(pure18(bind23(target5(ev))(fromEventTarget)))(function(buttonTarget) {
        return bind16(lift3(bind17(classList(toElement(buttonTarget)))(flip(contains4)("removeSubtitleButton"))))(function(hasRemoveClass) {
          return discard1(when5(!hasRemoveClass)(pure18(Nothing.value)))(function() {
            var buttonNode = toNode5(toElement(buttonTarget));
            return bind16(findTrAncestor(buttonNode))(function(tableRow) {
              return removeRowFromDom(tableRow);
            });
          });
        });
      });
    });
  };
  var removeSubtitleButtonEventListener = function(ev) {
    return applySecond4(runMaybeT(removeSubtitleButtonEventListenerTrans(ev)))(pure18(unit));
  };
  var setRemoveSubtitleButtonHandler = function(subtitleTable) {
    var tableRowEventTarget = function(r) {
      return toEventTarget2(toElement7(r));
    };
    return genericErrorsHandler(function __do5() {
      log("Setting up remove subtitle button handlers")();
      var evl = eventListener(removeSubtitleButtonEventListener)();
      var rows4 = getRows(subtitleTable)();
      traverse_2(function(r) {
        return addEventListener(click2)(evl)(false)(tableRowEventTarget(r));
      })(rows4)();
      return log("Remove subtitle button handler set up successfully")();
    });
  };
  var addRemoveSubtitleListenerToRow = function(row) {
    return function __do5() {
      var evl = eventListener(removeSubtitleButtonEventListener)();
      return addEventListener(click2)(evl)(false)(toEventTarget2(toElement7(row)))();
    };
  };

  // output/Handlers.AddSubtitleButtonHandler/index.js
  var pure19 = /* @__PURE__ */ pure(applicativeEffect);
  var bind18 = /* @__PURE__ */ bind(bindMaybe);
  var show14 = /* @__PURE__ */ show(showNumber);
  var cloneFirstRow = function(firstRow) {
    return function(subtitleTable) {
      return function __do5() {
        var tbody = getTBody(subtitleTable)();
        var clonedRowNode = deepClone(toNode3(firstRow))();
        var clonedRow = maybe(throwMinsiError(new HTMLElementNotFound("ClonedRow")))(pure19)(bind18(fromNode(clonedRowNode))(fromElement12))();
        var firstRowEndInput = getEndInput(firstRow)();
        var endValue = valueAsNumber(firstRowEndInput)();
        var clonedRowStartInput = getStartInput(clonedRow)();
        setValue2(show14(endValue))(clonedRowStartInput)();
        var newEndValue = endValue + 1;
        var clonedRowEndInput = getEndInput(clonedRow)();
        setValue2(show14(newEndValue))(clonedRowEndInput)();
        insertBefore(clonedRowNode)(toNode3(firstRow))(toNode4(tbody))();
        addRemoveSubtitleListenerToRow(clonedRow)();
        return log("Subtitle row cloned successfully")();
      };
    };
  };
  var addNewRow = function(subtitleTable) {
    return function(subtitleRowTemplate) {
      return function __do5() {
        var subtitleRow2 = getRow(subtitleRowTemplate)();
        var tbody = getTBody(subtitleTable)();
        var clonedRowNode = deepClone(toNode3(subtitleRow2))();
        var clonedRow = maybe(throwMinsiError(new HTMLElementNotFound("subtitleRow")))(pure19)(bind18(fromNode(clonedRowNode))(fromElement12))();
        appendChild(clonedRowNode)(toNode4(tbody))();
        addRemoveSubtitleListenerToRow(clonedRow)();
        return log("Subtitle row added successfully")();
      };
    };
  };
  var addSubtitleButtonEventListener = function(subtitleTable) {
    return function(subtitleRowTemplate) {
      return function(v) {
        return function __do5() {
          log("Add subtitle button clicked")();
          var eitherFirstRow = $$try(getFirstRow(subtitleTable))();
          if (eitherFirstRow instanceof Left) {
            return addNewRow(subtitleTable)(subtitleRowTemplate)();
          }
          ;
          if (eitherFirstRow instanceof Right) {
            return cloneFirstRow(eitherFirstRow.value0)(subtitleTable)();
          }
          ;
          throw new Error("Failed pattern match at Handlers.AddSubtitleButtonHandler (line 40, column 3 - line 42, column 59): " + [eitherFirstRow.constructor.name]);
        };
      };
    };
  };
  var setAddSubtitleButtonHandler = function(addSubtitleButton) {
    return function(subtitleTable) {
      return function(subtitleRowTemplate) {
        var addSubtitleButtonEventTarget = toEventTarget2(toElement(addSubtitleButton));
        return genericErrorsHandler(function __do5() {
          log("Setting up add subtitle button handler")();
          var addSubtitleButtonEvL = eventListener(addSubtitleButtonEventListener(subtitleTable)(subtitleRowTemplate))();
          addEventListener(click2)(addSubtitleButtonEvL)(false)(addSubtitleButtonEventTarget)();
          return log("Add subtitle button handler set up successfully")();
        });
      };
    };
  };

  // output/Handlers.SubtitleTimeButtonsHandler/index.js
  var show15 = /* @__PURE__ */ show(showNumber);
  var STBT = /* @__PURE__ */ function() {
    function STBT2(value0) {
      this.value0 = value0;
    }
    ;
    STBT2.create = function(value0) {
      return new STBT2(value0);
    };
    return STBT2;
  }();
  var setSubtitleStartButtonEventListener = function(subtitleTable) {
    return function(resultVideo) {
      return function(v) {
        return function __do5() {
          log("Set subtitle start button clicked")();
          var currentTimeValue = currentTime(toHTMLMediaElement(resultVideo))();
          var firstRow = getFirstRow(subtitleTable)();
          var startInput = getStartInput(firstRow)();
          setValue2(show15(currentTimeValue * 1e3))(startInput)();
          return log("Subtitle start time set successfully")();
        };
      };
    };
  };
  var setSubtitleEndButtonEventListener = function(subtitleTable) {
    return function(resultVideo) {
      return function(v) {
        return function __do5() {
          log("Set subtitle end button clicked")();
          var currentTimeValue = currentTime(toHTMLMediaElement(resultVideo))();
          var firstRow = getFirstRow(subtitleTable)();
          var endInput = getEndInput(firstRow)();
          setValue2(show15(currentTimeValue * 1e3))(endInput)();
          return log("Subtitle end time set successfully")();
        };
      };
    };
  };
  var setSubtitleTimeButtonsHandlers = function(v) {
    return genericErrorsHandler(function __do5() {
      var startButtonEvL = eventListener(setSubtitleStartButtonEventListener(v.value0.subtitleTable)(v.value0.resultVideo))();
      var endButtonEvL = eventListener(setSubtitleEndButtonEventListener(v.value0.subtitleTable)(v.value0.resultVideo))();
      addEventListener(click2)(startButtonEvL)(false)(toEventTarget2(toElement(v.value0.setSubtitleStartButton)))();
      addEventListener(click2)(endButtonEvL)(false)(toEventTarget2(toElement(v.value0.setSubtitleEndButton)))();
      return log("Subtitle time buttons handlers set up successfully")();
    });
  };

  // output/Web.UIEvent.KeyboardEvent/foreign.js
  function key(e) {
    return e.key;
  }
  function ctrlKey(e) {
    return e.ctrlKey;
  }
  function altKey(e) {
    return e.altKey;
  }
  function metaKey(e) {
    return e.metaKey;
  }

  // output/Web.UIEvent.KeyboardEvent/index.js
  var toEvent = unsafeCoerce2;
  var fromEvent = /* @__PURE__ */ unsafeReadProtoTagged("KeyboardEvent");

  // output/Web.UIEvent.KeyboardEvent.EventTypes/index.js
  var keydown = "keydown";

  // output/Handlers.KeyboardHandler/index.js
  var min5 = /* @__PURE__ */ min(ordNumber);
  var max6 = /* @__PURE__ */ max(ordNumber);
  var bind19 = /* @__PURE__ */ bind(bindMaybe);
  var when6 = /* @__PURE__ */ when(applicativeEffect);
  var applySecond5 = /* @__PURE__ */ applySecond(applyEffect);
  var pure20 = /* @__PURE__ */ pure(applicativeEffect);
  var KHT = /* @__PURE__ */ function() {
    function KHT2(value0) {
      this.value0 = value0;
    }
    ;
    KHT2.create = function(value0) {
      return new KHT2(value0);
    };
    return KHT2;
  }();
  var toggleResultVideoPlayback = function(video) {
    var media4 = toHTMLMediaElement(video);
    return function __do5() {
      var isPaused = paused(media4)();
      if (isPaused) {
        return play(media4)();
      }
      ;
      return pause(media4)();
    };
  };
  var skipSeconds = 0.5;
  var skipResultVideoForward = function(video) {
    var media4 = toHTMLMediaElement(video);
    return function __do5() {
      var t = currentTime(media4)();
      var d = duration(media4)();
      return setCurrentTime(min5(d)(t + skipSeconds))(media4)();
    };
  };
  var skipResultVideoBackward = function(video) {
    var media4 = toHTMLMediaElement(video);
    return function __do5() {
      var t = currentTime(media4)();
      return setCurrentTime(max6(0)(t - skipSeconds))(media4)();
    };
  };
  var isTargetEditableElement = function(ke) {
    return maybe(false)(function(el) {
      return isJust(fromElement4(el)) || (isJust(fromElement14(el)) || isJust(fromElement5(el)));
    })(bind19(target5(toEvent(ke)))(fromEventTarget2));
  };
  var handleKeyboardEvent = function(v) {
    return function(keyboardEvent) {
      var keyValue = key(keyboardEvent);
      var isMeta = metaKey(keyboardEvent);
      var isCtrl = ctrlKey(keyboardEvent);
      var isAlt = altKey(keyboardEvent);
      var ev = toEvent(keyboardEvent);
      var stop = preventDefault(ev);
      var whenNotEditable = function(cond) {
        return function(act) {
          return when6(cond && !isTargetEditableElement(keyboardEvent))(applySecond5(act)(stop));
        };
      };
      return function __do5() {
        when6(keyValue === "Enter" && (isCtrl || isMeta))(applySecond5(applyButtonEventListener(ev))(stop))();
        whenNotEditable(keyValue === " ")(toggleResultVideoPlayback(v.value0.resultVideo))();
        whenNotEditable(keyValue === "ArrowLeft")(skipResultVideoBackward(v.value0.resultVideo))();
        whenNotEditable(keyValue === "ArrowRight")(skipResultVideoForward(v.value0.resultVideo))();
        when6(keyValue === "?" && isCtrl)(applySecond5(showModal(v.value0.keyboardShortcutsModalId))(stop))();
        when6(keyValue === "s" && (isCtrl || isMeta))(applySecond5(rangeToNumberListener(v.value0.cutStart)(v.value0.cutStartValue)(ev))(stop))();
        when6(keyValue === "e" && (isCtrl || isMeta))(applySecond5(rangeToNumberListener(v.value0.cutEnd)(v.value0.cutEndValue)(ev))(stop))();
        when6(keyValue === "s" && isAlt)(applySecond5(setSubtitleStartButtonEventListener(v.value0.subtitleTable)(v.value0.resultVideo)(ev))(stop))();
        when6(keyValue === "e" && isAlt)(applySecond5(setSubtitleEndButtonEventListener(v.value0.subtitleTable)(v.value0.resultVideo)(ev))(stop))();
        when6(keyValue === "a" && isAlt)(applySecond5(addSubtitleButtonEventListener(v.value0.subtitleTable)(v.value0.subtitleRow)(ev))(stop))();
        return when6(keyValue === "r" && isAlt)(applySecond5(removeFirstSubtitleRow(v.value0.subtitleTable))(stop))();
      };
    };
  };
  var keyboardEventListener = function(targets) {
    return function(ev) {
      return maybe(pure20(unit))(handleKeyboardEvent(targets))(fromEvent(ev));
    };
  };
  var setKeyboardHandlers = function(targets) {
    var showShortcutsModal = function(v) {
      return showModal(v.value0.keyboardShortcutsModalId);
    };
    var keyboardShortcutsButton = function(v) {
      return v.value0.keyboardShortcutsButton;
    };
    return genericErrorsHandler(function __do5() {
      var w = windowImpl();
      var doc = document2(w)();
      var keyboardEvL = eventListener(keyboardEventListener(targets))();
      addEventListener(keydown)(keyboardEvL)(false)(toEventTarget(doc))();
      var shortcutsClickEvL = eventListener(function(v) {
        return showShortcutsModal(targets);
      })();
      return addEventListener(click2)(shortcutsClickEvL)(false)(toEventTarget2(toElement(keyboardShortcutsButton(targets))))();
    });
  };

  // output/Handlers.ResultVideo.Handler/index.js
  var RVET = /* @__PURE__ */ function() {
    function RVET2(value0) {
      this.value0 = value0;
    }
    ;
    RVET2.create = function(value0) {
      return new RVET2(value0);
    };
    return RVET2;
  }();
  var updatePlaybackPosition2 = function(playbackPositionResultVideo) {
    return function(resultVideo) {
      return function __do5() {
        var currentTimeValue = currentTime(toHTMLMediaElement(resultVideo))();
        return setTextContent(formatToThreeDecimals(currentTimeValue))(toNode2(playbackPositionResultVideo))();
      };
    };
  };
  var setResultVideoHandlers = function(v) {
    return genericErrorsHandler(function __do5() {
      setInterval2(1e3)(updatePlaybackPosition2(v.value0.playbackPositionResultVideo)(v.value0.resultVideo))();
      return unit;
    });
  };

  // output/Handlers.VideoSourceHandler/index.js
  var unwrap5 = /* @__PURE__ */ unwrap();
  var videoSourceEventListener = function(videoSource) {
    return function(video) {
      return function(v) {
        return genericErrorsHandler(function __do5() {
          var stateTuple = getCurrentState();
          var filename = unwrap5(fst(stateTuple)).filename;
          var selectedValue = value3(videoSource)();
          if (selectedValue === "video") {
            return setVideoSrc(mp4(filename))(video)();
          }
          ;
          if (selectedValue === "gif") {
            return setVideoSrc(gif(filename))(video)();
          }
          ;
          return log("\u26A0\uFE0F Unexpected VideoSource Input: " + selectedValue)();
        });
      };
    };
  };
  var setVideoSourceHandler = function(videoSource) {
    return function(video) {
      var videoSourceEventTarget = toEventTarget2(toElement4(videoSource));
      return genericErrorsHandler(function __do5() {
        var videoSourceEvL = eventListener(videoSourceEventListener(videoSource)(video))();
        return addEventListener(change)(videoSourceEvL)(false)(videoSourceEventTarget)();
      });
    };
  };

  // output/Handlers.Handlers/index.js
  var setupEventHandlers = function(v) {
    return function __do5() {
      setCutRangeHandlers(new CRET({
        cutStart: v.htmlInputs.value0.cutStart,
        cutEnd: v.htmlInputs.value0.cutEnd,
        cutEndValue: v.htmlOutputs.cutEndValue,
        cutStartValue: v.htmlOutputs.cutStartValue
      }))();
      setVideoHandlers(new VET({
        cutStart: v.htmlInputs.value0.cutStart,
        cutEnd: v.htmlInputs.value0.cutEnd,
        playbackPositionYoutube: v.htmlOutputs.playbackPositionYoutube,
        setCutStartButton: v.htmlInputs.value0.setCutStartButton,
        setCutEndButton: v.htmlInputs.value0.setCutEndButton,
        youtubeUrl: v.htmlInputs.value0.youtubeUrl,
        cutStartValue: v.htmlOutputs.cutStartValue,
        cutEndValue: v.htmlOutputs.cutEndValue
      }))();
      setResultVideoHandlers(new RVET({
        playbackPositionResultVideo: v.htmlOutputs.playbackPositionResultVideo,
        resultVideo: v.htmlOutputs.resultVideo
      }))();
      setApplyButtonHandler(v.htmlInputs.value0.applyButton)();
      setKeyboardHandlers(new KHT({
        cutStart: v.htmlInputs.value0.cutStart,
        cutEnd: v.htmlInputs.value0.cutEnd,
        cutStartValue: v.htmlOutputs.cutStartValue,
        cutEndValue: v.htmlOutputs.cutEndValue,
        subtitleTable: v.htmlInputs.value0.subtitleTable,
        subtitleRow: v.htmlInputs.value0.subtitleRow,
        resultVideo: v.htmlOutputs.resultVideo,
        keyboardShortcutsModalId,
        keyboardShortcutsButton: v.htmlOutputs.keyboardShortcutsButton
      }))();
      setAddSubtitleButtonHandler(v.htmlInputs.value0.addSubtitleButton)(v.htmlInputs.value0.subtitleTable)(v.htmlInputs.value0.subtitleRow)();
      setRemoveSubtitleButtonHandler(v.htmlInputs.value0.subtitleTable)();
      setSubtitleTimeButtonsHandlers(new STBT({
        setSubtitleStartButton: v.htmlInputs.value0.setSubtitleStartButton,
        setSubtitleEndButton: v.htmlInputs.value0.setSubtitleEndButton,
        subtitleTable: v.htmlInputs.value0.subtitleTable,
        resultVideo: v.htmlOutputs.resultVideo
      }))();
      return setVideoSourceHandler(v.htmlInputs.value0.videoSource)(v.htmlOutputs.resultVideo)();
    };
  };

  // output/Endpoints.CheckDependencies/index.js
  var pure21 = /* @__PURE__ */ pure(applicativeAff);
  var decodeJsonResponse3 = /* @__PURE__ */ decodeJsonResponse(/* @__PURE__ */ readForeignRecord()(/* @__PURE__ */ readForeignFieldsCons({
    reflectSymbol: function() {
      return "missedDependencies";
    }
  })(/* @__PURE__ */ readForeignArray(readForeignString))(readForeignFieldsNilRowRo)()()));
  var checkDependeciesEndpoint = /* @__PURE__ */ function() {
    return backendUrl + "checkDependencies";
  }();
  var callCheckDependencies = /* @__PURE__ */ function() {
    return bind(bindAff)(fetch2()()(toCoreRequestOptionsRowRo()()(toCoreRequestOptionsHelpe1(toCoreRequestOptionsConve9)()()()({
      reflectSymbol: function() {
        return "method";
      }
    })(toCoreRequestOptionsHelpe)()()))(checkDependeciesEndpoint)({
      method: POST.value
    }))(function(response) {
      if (response.ok) {
        return pure21({
          missedDependencies: []
        });
      }
      ;
      return decodeJsonResponse3("checkDependencies")(response);
    });
  }();

  // output/Main.CheckDependencies/index.js
  var $$null5 = /* @__PURE__ */ $$null(foldableArray);
  var pure23 = /* @__PURE__ */ pure(applicativeAff);
  var liftEffect9 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var checkDependecies = /* @__PURE__ */ bind(bindAff)(callCheckDependencies)(function(v) {
    var $6 = $$null5(v.missedDependencies);
    if ($6) {
      return pure23(unit);
    }
    ;
    return liftEffect9(throwMinsiError(new MissingDependenciesError(v.missedDependencies)));
  });

  // output/Main/index.js
  var program = function __do4() {
    runAff_(genericErrorsHandlerEither)(checkDependecies)();
    var doc = getDocument();
    var htmlComponents = loadComponents(doc)();
    log("Components correctly loaded")();
    setupEventHandlers(htmlComponents)();
    return log("Setup Handlers Done")();
  };
  var main = /* @__PURE__ */ genericErrorsHandler(program);

  // <stdin>
  main();
})();
