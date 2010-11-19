
var PeekScript = function () {
	this.init();
}

PeekScript.prototype.init = function () {

};

PeekScript.prototype.activateInspector = function (activate) {
	var self = this;
	var observer = function (ev) {
		self.selectedElement = ev.srcElement;
		alert(self.selectedElement);
		document.removeEventListener('touchstart', observer, true);
		ev.preventDefault();
		ev.stopPropagation();
	}
	document.addEventListener( 'touchstart', observer, true);
}
PeekScript.stringify = function (r) {
	if (r instanceof HTMLElement) {
		this.$0 = r;
		var element = r;
		var s = getComputedStyle(element, '');
		var elementInfo = [
			"width", "height",
			"marginTop", "marginLeft", "marginRight", "marginBottom",
			"paddingTop", "paddingLeft", "paddingRight", "paddingBottom",
			"borderTopWidth", "borderLeftWidth", "borderRightWidth", "borderBottomWidth",
			"position", "zIndex"
		].reduce( function(styles, name) {
			styles[name] = s[name];
			return styles;
		}, {});
		
		if (element instanceof HTMLAnchorElement) {
			elementInfo.text = '[object HTMLAnchorElement]'
		} else {
			elementInfo.text = element.toString()
		}
		elementInfo.attributes = {};
		Array.prototype.slice.apply(element.attributes).map( function (e) {
			elementInfo.attributes[e.name] = e.nodeValue;
		} )
		elementInfo.styles = PeekScript.stringify.appliedStylesInfomation(element);
		return {
			resultType: 'domnode',
			value: elementInfo
		}
	} else if (r instanceof Node) {
		return {
			resultType: 'node',
			value: r.toString()
		}
	} else if (r instanceof NodeList) {
		var a = [];
		for (var i = 0; i < r.length; i++) {
			a.push( PeekScript.stringify(r[i]) );
		}
		return {
			resultType: 'nodelist',
			value: a
		}
	} else if (r instanceof Array) {
		return {
			resultType: 'array',
			value: r
		}
	} else if (r instanceof Object) {
		do {
			var value;
			try {
				value = JSON.stringify(r);
			} catch(e) {
				try {
					value = r.toString();
				} catch(e) {
					value = 'Object';
				}
			
			}
		} while(0);
		return {
			resultType: 'object',
			value: value
		};
	} else {
		var value;
		if ( typeof r == 'undefined') {
			value = 'undefined'
		} else if (r === null)  {
			value = 'null'
		} else if (r === '')  {
			value = '(empty string)';
		} else if (r.toString)  {
			value = r.toString();
		}
		return {
			resultType: 'atom',
			value: value
		};
	}
}
PeekScript.stringify.appliedStylesInfomation = function (e) {
	var rules = getMatchedCSSRules(e)
	rules = Array.prototype.slice.apply(rules);
	var styles = rules.map(function (rule) {
		var url = null;
		if (rule.parentStyleSheet) {
			url = rule.parentStyleSheet.href;
			if ( !url ) {
				if ( rule.parentStyleSheet.ownerNode ) { 
					url = rule.parentStyleSheet.ownerNode.baseURI;
				}
			}
		}
		return {
			definition:  rule.cssText,
			url: url
		}
	} );
	if (e.style && e.style.cssText != '') {
		styles.unshift( {
			definition: e.style.cssText,
		});
	}
	return styles;
}


PeekScript.prototype.evaluate = function (code) {
	try {
		code = 'with(window.evaluationContext) {' + code  + '}'
		var r = eval(code);
		this.$0 = r;
		return JSON.stringify(PeekScript.stringify(r));
	} catch(e) {
		return JSON.stringify({resultType:'exception', name:e.name, line:e.line, message:e.message});
	}
}

window.$peekObject = new PeekScript();

window.evaluationContext = {
	$: function (id) {return document.getElementById(id)},
	$$: function (exp, context) { return Array.prototype.slice.apply(document.querySelectorAll(exp, context)) },
	get $0() { return window.$peekObject.selectedElement},
	$s: document.documentElement.innerHTML,
	$i: function () {window.$peekObject.activateInspector(true); return 1 },
}

1;
