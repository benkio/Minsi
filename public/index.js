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
  var $$void = function(dictFunctor) {
    return map(dictFunctor)($$const(unit));
  };
  var voidRight = function(dictFunctor) {
    var map13 = map(dictFunctor);
    return function(x) {
      return map13($$const(x));
    };
  };
  var functorArray = {
    map: arrayMap
  };

  // output/Control.Apply/index.js
  var identity2 = /* @__PURE__ */ identity(categoryFn);
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
    var map7 = map(dictApply.Functor0());
    return function(a) {
      return function(b) {
        return apply1(map7($$const(identity2))(a))(b);
      };
    };
  };

  // output/Control.Applicative/index.js
  var pure = function(dict) {
    return dict.pure;
  };
  var liftA1 = function(dictApplicative) {
    var apply2 = apply(dictApplicative.Apply0());
    var pure13 = pure(dictApplicative);
    return function(f) {
      return function(a) {
        return apply2(pure13(f))(a);
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
        for (var key in rec) {
          if ({}.hasOwnProperty.call(rec, key)) {
            copy[key] = rec[key];
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
      for (var key in rec) {
        if (key !== label4 && {}.hasOwnProperty.call(rec, key)) {
          copy[key] = rec[key];
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
  var topChar = String.fromCharCode(65535);
  var bottomChar = String.fromCharCode(0);
  var topNumber = Number.POSITIVE_INFINITY;
  var bottomNumber = Number.NEGATIVE_INFINITY;

  // output/Data.Ord/foreign.js
  var unsafeCompareImpl = function(lt) {
    return function(eq2) {
      return function(gt) {
        return function(x) {
          return function(y) {
            return x < y ? lt : x === y ? eq2 : gt;
          };
        };
      };
    };
  };
  var ordStringImpl = unsafeCompareImpl;

  // output/Data.Eq/foreign.js
  var refEq = function(r1) {
    return function(r2) {
      return r1 === r2;
    };
  };
  var eqStringImpl = refEq;

  // output/Data.Eq/index.js
  var eqString = {
    eq: eqStringImpl
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
  var compare = function(dict) {
    return dict.compare;
  };

  // output/Data.Show/foreign.js
  var showIntImpl = function(n) {
    return n.toString();
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
  var showArrayImpl = function(f) {
    return function(xs) {
      var ss = [];
      for (var i = 0, l = xs.length; i < l; i++) {
        ss[i] = f(xs[i]);
      }
      return "[" + ss.join(",") + "]";
    };
  };

  // output/Data.Show/index.js
  var showString = {
    show: showStringImpl
  };
  var showInt = {
    show: showIntImpl
  };
  var show = function(dict) {
    return dict.show;
  };
  var showArray = function(dictShow) {
    return {
      show: showArrayImpl(show(dictShow))
    };
  };

  // output/Data.Maybe/index.js
  var identity3 = /* @__PURE__ */ identity(categoryFn);
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
    return maybe$prime(a)(identity3);
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

  // output/Effect.Exception/foreign.js
  function error(msg) {
    return new Error(msg);
  }
  function message(e) {
    return e.message;
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
  var ap = function(dictMonad) {
    var bind7 = bind(dictMonad.Bind1());
    var pure8 = pure(dictMonad.Applicative0());
    return function(f) {
      return function(a) {
        return bind7(f)(function(f$prime) {
          return bind7(a)(function(a$prime) {
            return pure8(f$prime(a$prime));
          });
        });
      };
    };
  };

  // output/Data.Monoid/index.js
  var monoidArray = {
    mempty: [],
    Semigroup0: function() {
      return semigroupArray;
    }
  };
  var mempty = function(dict) {
    return dict.mempty;
  };

  // output/Effect/index.js
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
  var $lazy_functorEffect = /* @__PURE__ */ $runtime_lazy("functorEffect", "Effect", function() {
    return {
      map: liftA1(applicativeEffect)
    };
  });
  var $lazy_applyEffect = /* @__PURE__ */ $runtime_lazy("applyEffect", "Effect", function() {
    return {
      apply: ap(monadEffect),
      Functor0: function() {
        return $lazy_functorEffect(0);
      }
    };
  });
  var functorEffect = /* @__PURE__ */ $lazy_functorEffect(20);

  // output/Main.MinsiErrors/index.js
  var show2 = /* @__PURE__ */ show(/* @__PURE__ */ showArray(showString));
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
  var showMinsiError = {
    show: function(v) {
      if (v instanceof HTMLElementNotFound) {
        return "HTML Element couldn't be loaded: " + v.value0;
      }
      ;
      if (v instanceof MissingDependenciesError) {
        return "Missing following dependencies: " + show2(v.value0);
      }
      ;
      throw new Error("Failed pattern match at Main.MinsiErrors (line 12, column 10 - line 16, column 54): " + [v.constructor.name]);
    }
  };
  var throwMinsiError = /* @__PURE__ */ function() {
    var $10 = show(showMinsiError);
    return function($11) {
      return throwException(error($10($11)));
    };
  }();

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
  var map3 = /* @__PURE__ */ map(functorEffect);
  var getElementById = function(eid) {
    var $2 = map3(toMaybe);
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
        return function __do3() {
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
          throw new Error("Failed pattern match at Components.HTMLComponentsLoader (line 14, column 3 - line 16, column 33): " + [maybeComponentElement.constructor.name]);
        };
      };
    };
  };

  // output/Components.HtmlIds/index.js
  var youtubeUrlId = "youtubeUrl";
  var videoSourceId = "videoSource";
  var titleId = "title";
  var reverseLoopGifId = "reverseLoopGif";
  var resultPreviewId = "resultPreview";
  var playbackPositionId = "playbackPosition";
  var outputFilenameId = "outputFilename";
  var minsiLogId = "minsiLog";
  var cutStartId = "cutStart";
  var cutEndId = "cutEnd";
  var artistId = "artist";
  var applyId = "applyButton";
  var addSubtitleId = "addSubtitleButton";

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

  // output/Unsafe.Coerce/foreign.js
  var unsafeCoerce2 = function(x) {
    return x;
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
  var fromElement = /* @__PURE__ */ unsafeReadProtoTagged("HTMLButtonElement");

  // output/Web.HTML.HTMLDivElement/index.js
  var fromElement2 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLDivElement");

  // output/Web.HTML.HTMLInputElement/foreign.js
  function value2(input) {
    return function() {
      return input.value;
    };
  }

  // output/Web.HTML.HTMLInputElement/index.js
  var toElement = unsafeCoerce2;
  var fromElement3 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLInputElement");

  // output/Web.HTML.HTMLSelectElement/index.js
  var fromElement4 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLSelectElement");

  // output/Web.HTML.HTMLSpanElement/index.js
  var fromElement5 = /* @__PURE__ */ unsafeReadProtoTagged("HTMLSpanElement");

  // output/Components.HtmlComponents/index.js
  var HtmlOutputs = /* @__PURE__ */ function() {
    function HtmlOutputs2(value0) {
      this.value0 = value0;
    }
    ;
    HtmlOutputs2.create = function(value0) {
      return new HtmlOutputs2(value0);
    };
    return HtmlOutputs2;
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
  var loadYoutubeUrl = /* @__PURE__ */ loadHtmlElement(youtubeUrlId)(fromElement3);
  var loadVideoSource = /* @__PURE__ */ loadHtmlElement(videoSourceId)(fromElement4);
  var loadTitle = /* @__PURE__ */ loadHtmlElement(titleId)(fromElement3);
  var loadReverseLoop = /* @__PURE__ */ loadHtmlElement(reverseLoopGifId)(fromElement3);
  var loadResultPreview = /* @__PURE__ */ loadHtmlElement(resultPreviewId)(fromElement2);
  var loadPlaybackPosition = /* @__PURE__ */ loadHtmlElement(playbackPositionId)(fromElement5);
  var loadMinsiLog = /* @__PURE__ */ loadHtmlElement(minsiLogId)(fromElement2);
  var loadFilename = /* @__PURE__ */ loadHtmlElement(outputFilenameId)(fromElement3);
  var loadCutRange = function(doc) {
    return function __do3() {
      var cutStart = loadHtmlElement(cutStartId)(fromElement3)(doc)();
      var cutEnd = loadHtmlElement(cutEndId)(fromElement3)(doc)();
      return new Tuple(cutStart, cutEnd);
    };
  };
  var loadArtist = /* @__PURE__ */ loadHtmlElement(artistId)(fromElement3);
  var loadApplyButton = /* @__PURE__ */ loadHtmlElement(applyId)(fromElement);
  var loadAddSubtitleButton = /* @__PURE__ */ loadHtmlElement(addSubtitleId)(fromElement);
  var loadComponents = function(doc) {
    return function __do3() {
      var rangeTuple = loadCutRange(doc)();
      var youtubeUrl = loadYoutubeUrl(doc)();
      var filename = loadFilename(doc)();
      var reverseLoop = loadReverseLoop(doc)();
      var artist = loadArtist(doc)();
      var title2 = loadTitle(doc)();
      var applyButton = loadApplyButton(doc)();
      var videoSource = loadVideoSource(doc)();
      var resultPreview = loadResultPreview(doc)();
      var addSubtitleButton = loadAddSubtitleButton(doc)();
      var minsiLog = loadMinsiLog(doc)();
      var playbackPosition = loadPlaybackPosition(doc)();
      return new Tuple(new HtmlInputs({
        cutStart: fst(rangeTuple),
        cutEnd: snd(rangeTuple),
        youtubeUrl,
        filename,
        reverseLoop,
        artist,
        title: title2,
        applyButton,
        videoSource
      }), new HtmlOutputs({
        resultPreview,
        addSubtitleButton,
        minsiLog,
        playbackPosition
      }));
    };
  };

  // output/Web.HTML/foreign.js
  var windowImpl = function() {
    return window;
  };

  // output/Web.HTML.HTMLDocument/index.js
  var toNonElementParentNode = unsafeCoerce2;

  // output/Effect.Uncurried/foreign.js
  var mkEffectFn1 = function mkEffectFn12(fn) {
    return function(x) {
      return fn(x)();
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

  // output/Control.Plus/index.js
  var empty = function(dict) {
    return dict.empty;
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

  // output/Data.Bifunctor/index.js
  var identity4 = /* @__PURE__ */ identity(categoryFn);
  var bimap = function(dict) {
    return dict.bimap;
  };
  var lmap = function(dictBifunctor) {
    var bimap1 = bimap(dictBifunctor);
    return function(f) {
      return bimap1(f)(identity4);
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

  // output/Safe.Coerce/index.js
  var coerce = function() {
    return unsafeCoerce2;
  };

  // output/Data.Newtype/index.js
  var coerce2 = /* @__PURE__ */ coerce();
  var unwrap = function() {
    return coerce2;
  };

  // output/Data.Foldable/index.js
  var foldr = function(dict) {
    return dict.foldr;
  };
  var traverse_ = function(dictApplicative) {
    var applySecond2 = applySecond(dictApplicative.Apply0());
    var pure8 = pure(dictApplicative);
    return function(dictFoldable) {
      var foldr22 = foldr(dictFoldable);
      return function(f) {
        return foldr22(function($454) {
          return applySecond2(f($454));
        })(pure8(unit));
      };
    };
  };
  var foldl = function(dict) {
    return dict.foldl;
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
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
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
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v.constructor.name, v1.constructor.name, v2.constructor.name]);
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
          throw new Error("Failed pattern match at Data.Foldable (line 138, column 1 - line 144, column 27): " + [v.constructor.name, v1.constructor.name]);
        };
      };
    }
  };
  var foldMapDefaultR = function(dictFoldable) {
    var foldr22 = foldr(dictFoldable);
    return function(dictMonoid) {
      var append3 = append(dictMonoid.Semigroup0());
      var mempty3 = mempty(dictMonoid);
      return function(f) {
        return foldr22(function(x) {
          return function(acc) {
            return append3(f(x))(acc);
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
  var foldMap = function(dict) {
    return dict.foldMap;
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

  // output/Data.Traversable/index.js
  var traverse = function(dict) {
    return dict.traverse;
  };
  var traversableMaybe = {
    traverse: function(dictApplicative) {
      var pure8 = pure(dictApplicative);
      var map7 = map(dictApplicative.Apply0().Functor0());
      return function(v) {
        return function(v1) {
          if (v1 instanceof Nothing) {
            return pure8(Nothing.value);
          }
          ;
          if (v1 instanceof Just) {
            return map7(Just.create)(v(v1.value0));
          }
          ;
          throw new Error("Failed pattern match at Data.Traversable (line 115, column 1 - line 119, column 33): " + [v.constructor.name, v1.constructor.name]);
        };
      };
    },
    sequence: function(dictApplicative) {
      var pure8 = pure(dictApplicative);
      var map7 = map(dictApplicative.Apply0().Functor0());
      return function(v) {
        if (v instanceof Nothing) {
          return pure8(Nothing.value);
        }
        ;
        if (v instanceof Just) {
          return map7(Just.create)(v.value0);
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

  // output/Data.Semigroup.Foldable/index.js
  var JoinWith = function(x) {
    return x;
  };
  var semigroupJoinWith = function(dictSemigroup) {
    var append3 = append(dictSemigroup);
    return {
      append: function(v) {
        return function(v1) {
          return function(j) {
            return append3(v(j))(append3(j)(v1(j)));
          };
        };
      }
    };
  };
  var joinee = function(v) {
    return v;
  };
  var foldMap1 = function(dict) {
    return dict.foldMap1;
  };
  var intercalateMap = function(dictFoldable1) {
    var foldMap11 = foldMap1(dictFoldable1);
    return function(dictSemigroup) {
      var foldMap12 = foldMap11(semigroupJoinWith(dictSemigroup));
      return function(j) {
        return function(f) {
          return function(foldable) {
            return joinee(foldMap12(function($171) {
              return JoinWith($$const(f($171)));
            })(foldable))(j);
          };
        };
      };
    };
  };

  // output/Web.HTML.Window/foreign.js
  function document(window2) {
    return function() {
      return window2.document;
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
    return function __do3() {
      var w = windowImpl();
      return alert("\u{1F63E}!!! ERROR !!! \u{1F63E}\n" + msg)(w)();
    };
  };
  var getDocument = function __do() {
    var w = windowImpl();
    var d = document(w)();
    return toNonElementParentNode(d);
  };

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
  var $$try = function(dictMonadError) {
    var catchError1 = catchError(dictMonadError);
    var Monad0 = dictMonadError.MonadThrow0().Monad0();
    var map7 = map(Monad0.Bind1().Apply0().Functor0());
    var pure8 = pure(Monad0.Applicative0());
    return function(a) {
      return catchError1(map7(Right.create)(a))(function($52) {
        return pure8(Left.create($52));
      });
    };
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
      var size4 = 0;
      var ix = 0;
      var queue = new Array(limit);
      var draining = false;
      function drain() {
        var thunk;
        draining = true;
        while (size4 !== 0) {
          size4--;
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
          if (size4 === limit) {
            tmp = draining;
            drain();
            draining = tmp;
          }
          queue[(ix + size4) % limit] = cb;
          size4++;
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
      var fail2 = null;
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
                fail2 = util.left(e);
                step2 = null;
              }
              break;
            case STEP_RESULT:
              if (util.isLeft(step2)) {
                status2 = RETURN;
                fail2 = step2;
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
                  fail2 = util.left(step2._1);
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
                step2 = interrupt || fail2 || step2;
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
                    } else if (fail2) {
                      status2 = CONTINUE;
                      step2 = attempt._2(util.fromLeft(fail2));
                      fail2 = null;
                    }
                    break;
                  // We cannot resume from an unmasked interrupt or exception.
                  case RESUME:
                    if (interrupt && interrupt !== tmp && bracketCount === 0 || fail2) {
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
                    if (fail2 === null) {
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
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail2), attempts, interrupt);
                    status2 = CONTINUE;
                    if (interrupt && interrupt !== tmp && bracketCount === 0) {
                      step2 = attempt._1.killed(util.fromLeft(interrupt))(attempt._2);
                    } else if (fail2) {
                      step2 = attempt._1.failed(util.fromLeft(fail2))(attempt._2);
                    } else {
                      step2 = attempt._1.completed(util.fromRight(step2))(attempt._2);
                    }
                    fail2 = null;
                    bracketCount++;
                    break;
                  case FINALIZER:
                    bracketCount++;
                    attempts = new Aff2(CONS, new Aff2(FINALIZED, step2, fail2), attempts, interrupt);
                    status2 = CONTINUE;
                    step2 = attempt._1;
                    break;
                  case FINALIZED:
                    bracketCount--;
                    status2 = RETURN;
                    step2 = attempt._1;
                    fail2 = attempt._2;
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
              if (interrupt && fail2) {
                setTimeout(function() {
                  throw util.fromLeft(fail2);
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
      function onComplete(join3) {
        return function() {
          if (status2 === COMPLETED) {
            rethrow = rethrow && join3.rethrow;
            join3.handler(step2)();
            return function() {
            };
          }
          var jid = joinId++;
          joins = joins || {};
          joins[jid] = join3;
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
                fail2 = null;
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
                fail2 = null;
              }
          }
          return canceler;
        };
      }
      function join2(cb) {
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
        join: join2,
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
      function join2(result, head3, tail3) {
        var fail2, step2, lhs, rhs, tmp, kid;
        if (util.isLeft(result)) {
          fail2 = result;
          step2 = null;
        } else {
          step2 = result;
          fail2 = null;
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
            cb(fail2 || step2)();
            return;
          }
          if (head3._3 !== EMPTY) {
            return;
          }
          switch (head3.tag) {
            case MAP:
              if (fail2 === null) {
                head3._3 = util.right(head3._1(util.fromRight(step2)));
                step2 = head3._3;
              } else {
                head3._3 = fail2;
              }
              break;
            case APPLY:
              lhs = head3._1._3;
              rhs = head3._2._3;
              if (fail2) {
                head3._3 = fail2;
                tmp = true;
                kid = killId++;
                kills[kid] = kill(early, fail2 === lhs ? head3._2 : head3._1, function() {
                  return function() {
                    delete kills[kid];
                    if (tmp) {
                      tmp = false;
                    } else if (tail3 === null) {
                      join2(fail2, null, null);
                    } else {
                      join2(fail2, tail3._1, tail3._2);
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
                fail2 = step2 === lhs ? rhs : lhs;
                step2 = null;
                head3._3 = fail2;
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
                      join2(step2, null, null);
                    } else {
                      join2(step2, tail3._1, tail3._2);
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
            join2(result, fiber._2._1, fiber._2._2);
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
  function _makeFiber(util, aff) {
    return function() {
      return Aff.Fiber(util, null, aff);
    };
  }
  var _sequential = Aff.Seq;

  // output/Effect.Class/index.js
  var liftEffect = function(dict) {
    return dict.liftEffect;
  };

  // output/Control.Monad.Except.Trans/index.js
  var map4 = /* @__PURE__ */ map(functorEither);
  var ExceptT = function(x) {
    return x;
  };
  var withExceptT = function(dictFunctor) {
    var map13 = map(dictFunctor);
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
        return map13(mapLeft(f))(v);
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
    var map13 = map(dictFunctor);
    return {
      map: function(f) {
        return mapExceptT(map13(map4(f)));
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
    var bind7 = bind(dictMonad.Bind1());
    var pure8 = pure(dictMonad.Applicative0());
    return {
      bind: function(v) {
        return function(k) {
          return bind7(v)(either(function($193) {
            return pure8(Left.create($193));
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

  // output/Control.Parallel.Class/index.js
  var sequential = function(dict) {
    return dict.sequential;
  };
  var parallel = function(dict) {
    return dict.parallel;
  };

  // output/Control.Parallel/index.js
  var identity5 = /* @__PURE__ */ identity(categoryFn);
  var parTraverse_ = function(dictParallel) {
    var sequential2 = sequential(dictParallel);
    var parallel3 = parallel(dictParallel);
    return function(dictApplicative) {
      var traverse_2 = traverse_(dictApplicative);
      return function(dictFoldable) {
        var traverse_1 = traverse_2(dictFoldable);
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
        return parTraverse_2(dictFoldable)(identity5);
      };
    };
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
    return function __do3() {
      var fiber = makeFiber(aff)();
      fiber.run();
      return fiber;
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
  var $lazy_applyAff = /* @__PURE__ */ $runtime_lazy2("applyAff", "Effect.Aff", function() {
    return {
      apply: ap(monadAff),
      Functor0: function() {
        return functorAff;
      }
    };
  });
  var applyAff = /* @__PURE__ */ $lazy_applyAff(73);
  var pure2 = /* @__PURE__ */ pure(applicativeAff);
  var bindFlipped2 = /* @__PURE__ */ bindFlipped(bindAff);
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
      return parallel2(pure2($76));
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
  var $$try2 = /* @__PURE__ */ $$try(monadErrorAff);
  var runAff = function(k) {
    return function(aff) {
      return launchAff(bindFlipped2(function($83) {
        return liftEffect2(k($83));
      })($$try2(aff)));
    };
  };
  var runAff_ = function(k) {
    return function(aff) {
      return $$void2(runAff(k)(aff));
    };
  };
  var nonCanceler = /* @__PURE__ */ $$const(/* @__PURE__ */ pure2(unit));
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

  // output/Data.URL/foreign.js
  var fromStringImpl = (s) => {
    try {
      return new URL(s);
    } catch {
      return null;
    }
  };
  var hrefImpl = (u) => u.href;

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
  var functorNonEmpty = function(dictFunctor) {
    var map23 = map(dictFunctor);
    return {
      map: function(f) {
        return function(m) {
          return new NonEmpty(f(m.value0), map23(f)(m.value1));
        };
      }
    };
  };
  var foldableNonEmpty = function(dictFoldable) {
    var foldMap2 = foldMap(dictFoldable);
    var foldl3 = foldl(dictFoldable);
    var foldr3 = foldr(dictFoldable);
    return {
      foldMap: function(dictMonoid) {
        var append12 = append(dictMonoid.Semigroup0());
        var foldMap12 = foldMap2(dictMonoid);
        return function(f) {
          return function(v) {
            return append12(f(v.value0))(foldMap12(f)(v.value1));
          };
        };
      },
      foldl: function(f) {
        return function(b) {
          return function(v) {
            return foldl3(f)(f(b)(v.value0))(v.value1);
          };
        };
      },
      foldr: function(f) {
        return function(b) {
          return function(v) {
            return f(v.value0)(foldr3(f)(b)(v.value1));
          };
        };
      }
    };
  };
  var foldable1NonEmpty = function(dictFoldable) {
    var foldl3 = foldl(dictFoldable);
    var foldr3 = foldr(dictFoldable);
    var foldableNonEmpty1 = foldableNonEmpty(dictFoldable);
    return {
      foldMap1: function(dictSemigroup) {
        var append12 = append(dictSemigroup);
        return function(f) {
          return function(v) {
            return foldl3(function(s) {
              return function(a1) {
                return append12(s)(f(a1));
              };
            })(f(v.value0))(v.value1);
          };
        };
      },
      foldr1: function(f) {
        return function(v) {
          return maybe(v.value0)(f(v.value0))(foldr3(function(a1) {
            var $250 = maybe(a1)(f(a1));
            return function($251) {
              return Just.create($250($251));
            };
          })(Nothing.value)(v.value1));
        };
      },
      foldl1: function(f) {
        return function(v) {
          return foldl3(f)(v.value0)(v.value1);
        };
      },
      Foldable0: function() {
        return foldableNonEmpty1;
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
  var foldable1NonEmptyList = /* @__PURE__ */ foldable1NonEmpty(foldableList);
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

  // output/Data.Map.Internal/index.js
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
      throw new Error("Failed pattern match at Data.Map.Internal (line 702, column 5 - line 706, column 39): " + [r.constructor.name]);
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
      throw new Error("Failed pattern match at Data.Map.Internal (line 708, column 5 - line 712, column 68): " + [r.constructor.name]);
    }
    ;
    throw new Error("Failed pattern match at Data.Map.Internal (line 700, column 32 - line 712, column 68): " + [l.constructor.name]);
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
      throw new Error("Failed pattern match at Data.Map.Internal (line 757, column 12 - line 759, column 26): " + [v.constructor.name]);
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
      throw new Error("Failed pattern match at Data.Map.Internal (line 717, column 40 - line 738, column 34): " + [l.constructor.name]);
    };
  }();
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
            throw new Error("Failed pattern match at Data.Map.Internal (line 471, column 7 - line 474, column 35): " + [v2.constructor.name]);
          }
          ;
          throw new Error("Failed pattern match at Data.Map.Internal (line 468, column 8 - line 474, column 35): " + [v1.constructor.name]);
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
  var toLower = function(s) {
    return s.toLowerCase();
  };

  // output/Data.String.CodePoints/foreign.js
  var hasArrayFrom = typeof Array.from === "function";
  var hasStringIterator = typeof Symbol !== "undefined" && Symbol != null && typeof Symbol.iterator !== "undefined" && typeof String.prototype[Symbol.iterator] === "function";
  var hasFromCodePoint = typeof String.prototype.fromCodePoint === "function";
  var hasCodePointAt = typeof String.prototype.codePointAt === "function";

  // output/Data.String.Regex/foreign.js
  var showRegexImpl = function(r) {
    return "" + r;
  };
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
  var showRegex = {
    show: showRegexImpl
  };
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
  var singleton5 = /* @__PURE__ */ function() {
    var $200 = singleton2(plusList);
    return function($201) {
      return NonEmptyList($200($201));
    };
  }();

  // output/Foreign/index.js
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
  var fail = function(dictMonad) {
    var $153 = throwError(monadThrowExceptT(dictMonad));
    return function($154) {
      return $153(singleton5($154));
    };
  };
  var readArray = function(dictMonad) {
    var pure13 = pure(applicativeExceptT(dictMonad));
    var fail1 = fail(dictMonad);
    return function(value12) {
      if (isArray(value12)) {
        return pure13(unsafeFromForeign(value12));
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
    var pure13 = pure(applicativeExceptT(dictMonad));
    var fail1 = fail(dictMonad);
    return function(tag) {
      return function(value12) {
        if (tagOf(value12) === tag) {
          return pure13(unsafeFromForeign(value12));
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
  function unsafeReadPropImpl(f, s, key, value12) {
    return value12 == null ? f : s(value12[key]);
  }

  // output/Foreign.Index/index.js
  var unsafeReadProp = function(dictMonad) {
    var fail2 = fail(dictMonad);
    var pure8 = pure(applicativeExceptT(dictMonad));
    return function(k) {
      return function(value12) {
        return unsafeReadPropImpl(fail2(new TypeMismatch("object", typeOf(value12))), pure8, k, value12);
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
    for (var key in rec) {
      if ({}.hasOwnProperty.call(rec, key)) {
        copy[key] = rec[key];
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
  var show3 = /* @__PURE__ */ show(showString);
  var toString = hrefImpl;
  var showURL = {
    show: function(u) {
      return "(URL " + (show3(toString(u)) + ")");
    }
  };
  var fromString2 = function($255) {
    return toMaybe(fromStringImpl($255));
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
  var showV = function(dictShow) {
    var show8 = show(dictShow);
    return function(dictShow1) {
      var show1 = show(dictShow1);
      return {
        show: function(v) {
          if (v instanceof Left) {
            return "invalid (" + (show8(v.value0) + ")");
          }
          ;
          if (v instanceof Right) {
            return "pure (" + (show1(v.value0) + ")");
          }
          ;
          throw new Error("Failed pattern match at Data.Validation.Semigroup (line 81, column 10 - line 83, column 55): " + [v.constructor.name]);
        }
      };
    };
  };
  var invalid = function($100) {
    return V(Left.create($100));
  };
  var functorV = functorEither;
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

  // output/Validations.RegexValidation/index.js
  var pure3 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeV(semigroupArray));
  var show4 = /* @__PURE__ */ show(showRegex);
  var matches = function(v) {
    return function(v1) {
      if (test(v)(v1)) {
        return pure3(v1);
      }
      ;
      return invalid(["Input does not matches the requested format, value: " + (v1 + (" regex: " + show4(v)))]);
    };
  };

  // output/Validations.YoutubeValidation/index.js
  var pure4 = /* @__PURE__ */ pure(/* @__PURE__ */ applicativeV(semigroupArray));
  var youtubeRegex = "(http:|https:)?(\\/\\/)?(www\\.)?(youtube.com|youtu.be)\\/(watch|embed)?(\\?v=|\\/)?(\\S+)?";
  var youtubeRegexValidation = /* @__PURE__ */ lmap(bifunctorEither)(function(x) {
    return [x];
  })(/* @__PURE__ */ regex(youtubeRegex)(noFlags));
  var youtubeUrlValidation = function(v) {
    return andThen(andThen(youtubeRegexValidation)(function(ytRegex) {
      return matches(ytRegex)(v);
    }))(function(urlString) {
      return maybe(invalid(["Error validating youtube Url"]))(pure4)(fromString2(urlString));
    });
  };

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

  // output/Web.DOM.ParentNode/foreign.js
  var getEffProp = function(name15) {
    return function(node) {
      return function() {
        return node[name15];
      };
    };
  };
  var children = getEffProp("children");
  var _firstElementChild = getEffProp("firstElementChild");
  var _lastElementChild = getEffProp("lastElementChild");
  var childElementCount = getEffProp("childElementCount");

  // output/Web.DOM.Element/index.js
  var toEventTarget = unsafeCoerce2;
  var fromEventTarget = /* @__PURE__ */ unsafeReadProtoTagged("Element");

  // output/Web.Event.Event/foreign.js
  function _target(e) {
    return e.target;
  }

  // output/Web.Event.Event/index.js
  var target5 = function($3) {
    return toMaybe(_target($3));
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
  var change = "change";

  // output/Handlers.Handlers/index.js
  var traverse2 = /* @__PURE__ */ traverse(traversableMaybe)(applicativeEffect);
  var bind2 = /* @__PURE__ */ bind(bindMaybe);
  var show5 = /* @__PURE__ */ show(/* @__PURE__ */ showV(/* @__PURE__ */ showArray(showString))(showURL));
  var getInputValue = function(ev) {
    return traverse2(value2)(bind2(bind2(target5(ev))(fromEventTarget))(fromElement3));
  };
  var youtubeUrlEventListener = function(ev) {
    return function __do3() {
      var rawValue = getInputValue(ev)();
      var youtubeUrlV = maybe(invalid(["Empty YoutubeUrl Input"]))(youtubeUrlValidation)(rawValue);
      return log("Youtube Url Handler fired with value: " + show5(youtubeUrlV))();
    };
  };
  var setupEventHandlers = function(v) {
    return function __do3() {
      var ytEvL = eventListener(youtubeUrlEventListener)();
      return addEventListener(change)(ytEvL)(false)(toEventTarget(toElement(v.value0.value0.youtubeUrl)))();
    };
  };

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
  function _toArray(tuple, headers2) {
    return Array.from(headers2.entries(), function(pair) {
      return tuple(pair[0])(pair[1]);
    });
  }

  // output/JS.Fetch.Headers/index.js
  var toArray2 = /* @__PURE__ */ function() {
    return runFn2(_toArray)(Tuple.create);
  }();

  // output/Fetch.Internal.Headers/index.js
  var toHeaders = /* @__PURE__ */ function() {
    var $7 = fromFoldable(ordCaseInsensitiveString)(foldableArray);
    var $8 = map(functorArray)(lmap(bifunctorTuple)(CaseInsensitiveString));
    return function($9) {
      return $7($8(toArray2($9)));
    };
  }();

  // output/JS.Fetch.Request/foreign.js
  function _unsafeNew(url2, options2) {
    try {
      return new Request(url2, options2);
    } catch (e) {
      console.error(e);
      throw e;
    }
  }

  // output/Fetch.Internal.Request/index.js
  var show6 = /* @__PURE__ */ show(showMethod);
  var toCoreRequestOptionsHelpe = {
    convertHelper: function(v) {
      return function(v1) {
        return {};
      };
    }
  };
  var toCoreRequestOptionsConve9 = {
    convertImpl: function(v) {
      return show6;
    }
  };
  var $$new2 = function() {
    return function(url2) {
      return function(options2) {
        return function() {
          return _unsafeNew(url2, options2);
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
            var $$delete3 = $$delete2(dictIsSymbol)()();
            var get3 = get(dictIsSymbol)();
            var insert7 = insert3(dictIsSymbol)()();
            return function(dictToCoreRequestOptionsHelper) {
              var convertHelper1 = convertHelper(dictToCoreRequestOptionsHelper);
              return function() {
                return function() {
                  return {
                    convertHelper: function(v) {
                      return function(r) {
                        var tail3 = convertHelper1($$Proxy.value)($$delete3($$Proxy.value)(r));
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
  function url(resp) {
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
  var map5 = /* @__PURE__ */ map(functorEffect);
  var resolve3 = /* @__PURE__ */ resolve2();
  var alt5 = /* @__PURE__ */ alt(altMaybe);
  var map1 = /* @__PURE__ */ map(functorMaybe);
  var readString3 = /* @__PURE__ */ readString(monadIdentity);
  var bind3 = /* @__PURE__ */ bind(bindAff);
  var liftEffect3 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var toAff$prime = function(customCoerce) {
    return function(p) {
      return makeAff(function(cb) {
        return voidRight2(mempty2)(thenOrCatch3(function(a) {
          return map5(resolve3)(cb(new Right(a)));
        })(function(e) {
          return map5(resolve3)(cb(new Left(customCoerce(e))));
        })(p));
      });
    };
  };
  var coerce3 = function(rej) {
    return fromMaybe$prime(function(v) {
      return error("Promise failed, couldn't extract JS Error or String");
    })(alt5(toError(rej))(map1(error)(hush(runExcept(readString3(unsafeToForeign(rej)))))));
  };
  var toAff = /* @__PURE__ */ toAff$prime(coerce3);
  var toAffE = function(f) {
    return bind3(liftEffect3(f))(toAff);
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
      url: url(response),
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
  var $$void3 = /* @__PURE__ */ $$void(functorEffect);
  var thenOrCatch4 = /* @__PURE__ */ thenOrCatch2();
  var map6 = /* @__PURE__ */ map(functorEffect);
  var resolve4 = /* @__PURE__ */ resolve2();
  var bind4 = /* @__PURE__ */ bind(bindAff);
  var liftEffect4 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var $$new4 = /* @__PURE__ */ $$new2();
  var bindFlipped3 = /* @__PURE__ */ bindFlipped(bindAff);
  var fetchWithOptions2 = /* @__PURE__ */ fetchWithOptions();
  var pure1 = /* @__PURE__ */ pure(applicativeAff);
  var toAbortableAff = function(abortController) {
    return function(p) {
      return makeAff(function(cb) {
        return function __do3() {
          $$void3(thenOrCatch4(function(a) {
            return map6(resolve4)(cb(new Right(a)));
          })(function(e) {
            return map6(resolve4)(cb(new Left(coerce3(e))));
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
        return function(url2) {
          return function(r) {
            return bind4(liftEffect4($$new4(url2)(convert3(r))))(function(request) {
              return bind4(liftEffect4(newImpl3))(function(abortController) {
                var signal2 = signal(abortController);
                return bind4(bindFlipped3(toAbortableAff(abortController))(liftEffect4(fetchWithOptions2(request)({
                  signal: signal2
                }))))(function(cResponse) {
                  return pure1(convert2(cResponse));
                });
              });
            });
          };
        };
      };
    };
  };

  // output/Yoga.JSON/index.js
  var identity6 = /* @__PURE__ */ identity(categoryBuilder);
  var readString4 = /* @__PURE__ */ readString(monadIdentity);
  var bindExceptT2 = /* @__PURE__ */ bindExceptT(monadIdentity);
  var except2 = /* @__PURE__ */ except(applicativeIdentity);
  var applicativeExceptT2 = /* @__PURE__ */ applicativeExceptT(monadIdentity);
  var pure12 = /* @__PURE__ */ pure(applicativeExceptT2);
  var compose1 = /* @__PURE__ */ compose(semigroupoidBuilder);
  var insert6 = /* @__PURE__ */ insert4()();
  var append2 = /* @__PURE__ */ append(semigroupNonEmptyList);
  var functorExceptT2 = /* @__PURE__ */ functorExceptT(functorIdentity);
  var map12 = /* @__PURE__ */ map(functorExceptT2);
  var map22 = /* @__PURE__ */ map(functorNonEmptyList);
  var bindFlipped4 = /* @__PURE__ */ bindFlipped(bindExceptT2);
  var composeKleisliFlipped2 = /* @__PURE__ */ composeKleisliFlipped(bindExceptT2);
  var readProp2 = /* @__PURE__ */ readProp(monadIdentity);
  var mapWithIndex3 = /* @__PURE__ */ mapWithIndex(functorWithIndexArray);
  var readArray2 = /* @__PURE__ */ readArray(monadIdentity);
  var readForeignString = {
    readImpl: readString4
  };
  var readForeignFieldsNilRowRo = {
    getFields: function(v) {
      return function(v1) {
        return pure12(identity6);
      };
    }
  };
  var sequenceCombining = function(dictMonoid) {
    var append22 = append(dictMonoid.Semigroup0());
    var mempty3 = mempty(dictMonoid);
    return function(dictFoldable) {
      var foldl3 = foldl(dictFoldable);
      return function(dictApplicative) {
        var pure22 = pure(dictApplicative);
        var fn = function(acc) {
          return function(elem3) {
            var v = runExcept(elem3);
            if (acc instanceof Left && v instanceof Left) {
              return new Left(append2(acc.value0)(v.value0));
            }
            ;
            if (acc instanceof Left && v instanceof Right) {
              return new Left(acc.value0);
            }
            ;
            if (acc instanceof Right && v instanceof Right) {
              return new Right(append22(acc.value0)(pure22(v.value0)));
            }
            ;
            if (acc instanceof Right && v instanceof Left) {
              return new Left(v.value0);
            }
            ;
            throw new Error("Failed pattern match at Yoga.JSON (line 653, column 5 - line 657, column 37): " + [acc.constructor.name, v.constructor.name]);
          };
        };
        var $505 = foldl3(fn)(new Right(mempty3));
        return function($506) {
          return except2($505($506));
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
        var $542 = mapWithIndex3(readAtIdx(dictReadForeign));
        return function($543) {
          return sequenceCombining1($542($543));
        };
      }())(readArray2)
    };
  };
  var read3 = function(dictReadForeign) {
    var $544 = readImpl2(dictReadForeign);
    return function($545) {
      return runExcept($544($545));
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
                  var value12 = enrichErrorWithPropName(bindFlipped4(readImpl5)(readProp2(name15)(obj)));
                  var first = map12(insert42($$Proxy.value))(value12);
                  return except2(function() {
                    var v1 = runExcept(rest);
                    var v2 = runExcept(first);
                    if (v2 instanceof Right && v1 instanceof Right) {
                      return new Right(compose1(v2.value0)(v1.value0));
                    }
                    ;
                    if (v2 instanceof Left && v1 instanceof Left) {
                      return new Left(append2(v2.value0)(v1.value0));
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
                    throw new Error("Failed pattern match at Yoga.JSON (line 360, column 5 - line 364, column 33): " + [v2.constructor.name, v1.constructor.name]);
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
          return map12(flip(build)({}))(getFields1($$Proxy.value)(o));
        }
      };
    };
  };

  // output/Yoga.JSON.Error/index.js
  var show7 = /* @__PURE__ */ show(showInt);
  var toJSONPath = function(fe) {
    var go2 = function(v) {
      if (v instanceof ForeignError) {
        return "";
      }
      ;
      if (v instanceof TypeMismatch) {
        return "";
      }
      ;
      if (v instanceof ErrorAtIndex) {
        return "[" + (show7(v.value0) + ("]" + go2(v.value1)));
      }
      ;
      if (v instanceof ErrorAtProperty && (v.value1 instanceof TypeMismatch && v.value1.value1 === "undefined")) {
        return "";
      }
      ;
      if (v instanceof ErrorAtProperty) {
        return "." + (v.value0 + go2(v.value1));
      }
      ;
      throw new Error("Failed pattern match at Yoga.JSON.Error (line 11, column 8 - line 16, column 49): " + [v.constructor.name]);
    };
    var path = go2(fe);
    return "$" + path;
  };
  var errorToJSON = function(err) {
    var path = toJSONPath(err);
    var go2 = function($copy_v) {
      var $tco_done = false;
      var $tco_result;
      function $tco_loop(v) {
        if (v instanceof ForeignError) {
          $tco_done = true;
          return {
            path,
            message: v.value0
          };
        }
        ;
        if (v instanceof TypeMismatch && v.value1 === "Undefined") {
          $tco_done = true;
          return {
            path,
            message: "Must provide a value of type '" + (v.value0 + "'")
          };
        }
        ;
        if (v instanceof TypeMismatch && v.value1 === "undefined") {
          $tco_done = true;
          return {
            path,
            message: "Must provide a value of type '" + (v.value0 + "'")
          };
        }
        ;
        if (v instanceof TypeMismatch) {
          $tco_done = true;
          return {
            path,
            message: "Must provide a value of type '" + (v.value0 + ("' instead of '" + (v.value1 + "'")))
          };
        }
        ;
        if (v instanceof ErrorAtIndex) {
          $copy_v = v.value1;
          return;
        }
        ;
        if (v instanceof ErrorAtProperty) {
          $copy_v = v.value1;
          return;
        }
        ;
        throw new Error("Failed pattern match at Yoga.JSON.Error (line 31, column 8 - line 49, column 31): " + [v.constructor.name]);
      }
      ;
      while (!$tco_done) {
        $tco_result = $tco_loop($copy_v);
      }
      ;
      return $tco_result;
    };
    return go2(err);
  };
  var renderHumanError = /* @__PURE__ */ function() {
    var toHuman = function(v) {
      return v.message + (" at " + v.path);
    };
    return function($33) {
      return toHuman(errorToJSON($33));
    };
  }();

  // output/Fetch.Yoga.Json/index.js
  var intercalateMap2 = /* @__PURE__ */ intercalateMap(foldable1NonEmptyList)(semigroupString);
  var bind5 = /* @__PURE__ */ bind(bindAff);
  var throwError2 = /* @__PURE__ */ throwError(monadThrowAff);
  var pure5 = /* @__PURE__ */ pure(applicativeAff);
  var fromJSON = function(dictReadForeign) {
    var read4 = read3(dictReadForeign);
    return function(json3) {
      var toError2 = function() {
        var $8 = intercalateMap2("\n")(renderHumanError);
        return function($9) {
          return error($8($9));
        };
      }();
      return bind5(json3)(function() {
        var $10 = either(function($12) {
          return throwError2(toError2($12));
        })(pure5);
        return function($11) {
          return $10(read4($11));
        };
      }());
    };
  };

  // output/Main.Config/index.js
  var backendUrl = "http://localhost:8080/";

  // output/Main.CheckDependencies/index.js
  var bind6 = /* @__PURE__ */ bind(bindAff);
  var fromJSON2 = /* @__PURE__ */ fromJSON(/* @__PURE__ */ readForeignRecord()(/* @__PURE__ */ readForeignFieldsCons({
    reflectSymbol: function() {
      return "missedDependencies";
    }
  })(/* @__PURE__ */ readForeignArray(readForeignString))(readForeignFieldsNilRowRo)()()));
  var liftEffect5 = /* @__PURE__ */ liftEffect(monadEffectAff);
  var pure6 = /* @__PURE__ */ pure(applicativeAff);
  var missingDependencies = function(jsonText) {
    return bind6(fromJSON2(jsonText))(function(v) {
      return liftEffect5(throwMinsiError(new MissingDependenciesError(v.missedDependencies)));
    });
  };
  var checkDependeciesEndpoint = /* @__PURE__ */ function() {
    return backendUrl + "checkDependencies";
  }();
  var checkDependecies = /* @__PURE__ */ function() {
    return bind6(fetch2()()(toCoreRequestOptionsRowRo()()(toCoreRequestOptionsHelpe1(toCoreRequestOptionsConve9)()()()({
      reflectSymbol: function() {
        return "method";
      }
    })(toCoreRequestOptionsHelpe)()()))(checkDependeciesEndpoint)({
      method: POST.value
    }))(function(response) {
      if (response.ok) {
        return pure6(unit);
      }
      ;
      return missingDependencies(response.json);
    });
  }();

  // output/Main/index.js
  var pure7 = /* @__PURE__ */ pure(applicativeEffect);
  var catchError2 = /* @__PURE__ */ catchError(monadErrorEffect);
  var genericErrorsHandlerEither = function(v) {
    if (v instanceof Right) {
      return pure7(unit);
    }
    ;
    if (v instanceof Left) {
      return raiseErrorAlert(message(v.value0));
    }
    ;
    throw new Error("Failed pattern match at Main (line 31, column 1 - line 31, column 70): " + [v.constructor.name]);
  };
  var program = function __do2() {
    runAff_(genericErrorsHandlerEither)(checkDependecies)();
    var doc = getDocument();
    var htmlComponents = loadComponents(doc)();
    log("Components correctly loaded")();
    setupEventHandlers(htmlComponents)();
    return log("Setup Handlers Done")();
  };
  var genericErrorsHandler = function(p) {
    return catchError2(p)(function(e) {
      return raiseErrorAlert(message(e));
    });
  };
  var main = /* @__PURE__ */ genericErrorsHandler(program);

  // <stdin>
  main();
})();
