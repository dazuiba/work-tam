var Fe=Fe||{
    version:"20080809",
    emptyFn:function(){}
};
Fe.each=function(D,E){
    if(typeof E!="function"){
        return D
    }if(D){
        if(D.length===undefined){
            for(var A in D){
                E.call(D[A],D[A],A)
            }
        }else{
            for(var B=0,C=D.length;B<C;B++){
                E.call(D[B],D[B],B)
            }
        }
    }return D
};
Fe.body=function(){
    var F=0,D=0,A=0,J=0,I=0,E=0;var B=window,S=document,C=S.documentElement;F=C.clientWidth||S.body.clientWidth;D=B.innerHeight||C.clientHeight||S.body.clientHeight;J=S.body.scrollTop||C.scrollTop;A=S.body.scrollLeft||C.scrollLeft;I=Math.max(S.body.scrollWidth,C.scrollWidth||0);E=Math.max(S.body.scrollHeight,C.scrollHeight||0,D);return{
        scrollTop:J,
        scrollLeft:A,
        documentWidth:I,
        documentHeight:E,
        viewWidth:F,
        viewHeight:D
    }
};
Fe.extend=function(E,C){
    if(E&&C&&typeof (C)=="object"){
        for(var D in C){
            E[D]=C[D]
        }var B=["constructor","hasOwnProperty","isPrototypeOf","propertyIsEnumerable","toLocaleString","toString","valueOf"];for(var F=0,A;F<B.length;F++){
            A=B[F];if(Object.prototype.hasOwnProperty.call(C,A)){
                E[A]=C[A]
            }
        }
    }return E
};
Fe.isIE=0;(function(){
    if(navigator.userAgent.indexOf("MSIE")>0&&!window.opera){
        /MSIE (\d+(\.\d+)?)/.test(navigator.userAgent);Fe.isIE=parseFloat(RegExp.$1)
    }
})();
Fe.Browser=(function(){
    var F=navigator.userAgent;var B=0,D=0,A=0,Q=0;var H=0,C=0,E=0;if(typeof (window.opera)=="object"&&/Opera(\s|\/)(\d+(\.\d+)?)/.test(F)){
        D=parseFloat(RegExp.$2)
    }else{
        if(/MSIE (\d+(\.\d+)?)/.test(F)){
            B=parseFloat(RegExp.$1)
        }else{
            if(/Firefox(\s|\/)(\d+(\.\d+)?)/.test(F)){
                Q=parseFloat(RegExp.$2)
            }else{
                if(navigator.vendor=="Netscape"&&/Netscape(\s|\/)(\d+(\.\d+)?)/.test(F)){
                    E=parseFloat(RegExp.$2)
                }else{
                    if(F.indexOf("Safari")>-1&&/Version\/(\d+(\.\d+)?)/.test(F)){
                        A=parseFloat(RegExp.$1)
                    }
                }
            }
        }
    }if(F.indexOf("Gecko")>-1&&F.indexOf("KHTML")==-1&&/rv\:(\d+(\.\d+)?)/.test(F)){
        C=parseFloat(RegExp.$1)
    }return{
        ie:B,
        firefox:Q,
        gecko:C,
        netscape:E,
        opera:D,
        safari:A
    }
})();

window.FeBrowser=Fe.Browser;
Fe.G=function(){
    for(var C=[],A=arguments.length-1;A>-1;A--){
        var B=arguments[A];C[A]=null;if(typeof B=="object"&&B&&B.dom){
            C[A]=B.dom
        }else{
            if((typeof B=="object"&&B&&B.tagName)||B==window||B==document){
                C[A]=B
            }else{
                if(typeof B=="string"&&(B=document.getElementById(B))){
                    C[A]=B
                }
            }
        }
    }return C.length<2?C[0]:C
};

Fe.hide=function(){
    Fe.each(arguments,function(A){
        if(A=Fe.G(A)){
            A.style.display="none"
        }
    })
};

Fe.show=function(){
    this.each(arguments,function(A){
        if(A=Fe.G(A)){
            A.style.display=""
        }
    })
};

Fe.on=function(B,A,C){
    if(!(B=Fe.G(B))){
        return B
    }A=A.replace(/^on/,"").toLowerCase();if(B.attachEvent){
        B[A+C]=function(){
            C.call(B,window.event)
        };B.attachEvent("on"+A,B[A+C])
    }else{
        B.addEventListener(A,C,false)
    }return B
};

Fe.un=function(B,A,C){
    if(!(B=Fe.G(B))){
        return B
    }A=A.replace(/^on/,"").toLowerCase();if(B.attachEvent){
        B.detachEvent("on"+A,B[A+C]);B[A+C]=null
    }else{
        B.removeEventListener(A,C,false)
    }return B
};

Fe.Dom={};
Fe.isIE=/MSIE (\d+(\.\d+)?)/.test(navigator.userAgent)?RegExp.$1:0;
Fe.isOpera=(window.opera&&/Opera(\s|\/)(\d+(\.\d+)?)/.test(navigator.userAgent))?RegExp.$2:0;
Fe.isSafari=(navigator.userAgent.indexOf("Safari")>-1&&/Version\/(\d+(\.\d+)?)/.test(navigator.userAgent))?RegExp.$1:0;
Fe.Dom.ready=function(){
    var B=false,D=false,C=[];function E(){
        if(!B){
            B=true;for(var I=0,H=C.length;I<H;I++){
                try{
                    C[I]()
                }catch(F){}
            }
        }
    }function A(){
        if(D){
            return
        }D=true;if(document.addEventListener&&!Fe.isOpera){
            document.addEventListener("DOMContentLoaded",E,false)
        }if(Fe.isIE&&window==top){
            (function(){
                if(B){
                    return
                }try{
                    document.documentElement.doScroll("left")
                }catch(H){
                    setTimeout(arguments.callee,0);return
                }E()
            })()
        }if(Fe.isOpera){
            document.addEventListener("DOMContentLoaded",function(){
                if(B){
                    return
                }for(var H=0;H<document.styleSheets.length;H++){
                    if(document.styleSheets[H].disabled){
                        setTimeout(arguments.callee,0);return
                    }
                }E()
            },false)
        }if(Fe.isSafari){
            var F;(function(){
                if(B){
                    return
                }if(document.readyState!="loaded"&&document.readyState!="complete"){
                    setTimeout(arguments.callee,0);return
                }if(F===undefined){
                    F=0;var K=document.getElementsByTagName("style");var I=document.getElementsByTagName("link");if(K){
                        F+=K.length
                    }if(I){
                        for(var J=0,H=I.length;J<H;J++){
                            if(I[J].getAttribute("rel")=="stylesheet"){
                                F++
                            }
                        }
                    }
                }if(document.styleSheets.length!=F){
                    setTimeout(arguments.callee,0);return
                }E()
            })()
        }if(window.attachEvent){
            window.attachEvent("onload",E)
        }else{
            window.addEventListener("load",E,false)
        }
    }return function(F){
        if(typeof F!="function"){
            return false
        }A();if(B){
            F()
        }else{
            C[C.length]=F
        }
    }
}();

Fe.ready=Fe.Dom.ready;Fe.css=function(O,D){
    if(!O||!D){
        return null
    }O=typeof O=="string"?document.getElementById(O):O;var F=!window.opera&&navigator.userAgent.indexOf("MSIE")!=-1;if(D=="float"){
        D=F?"styleFloat":"cssFloat"
    }D=D.replace(/(-[a-z])/gi,function(I,H){
        return H.charAt(1).toUpperCase()
    });if("opacity"==D&&F){
        var E=O.style.filter;return E&&E.indexOf("opacity=")>=0?(parseFloat(E.match(/opacity=([^)]*)/)[1])/100)+"":"1"
    }var C=null;if(C=O.style[D]){
        return C
    }if(O.currentStyle){
        return O.currentStyle[D]
    }else{
        var B=O.nodeType==9?O:O.ownerDocument||O.document;if(B.defaultView&&B.defaultView.getComputedStyle){
            var A=B.defaultView.getComputedStyle(O,"");if(A){
                return A[D]
            }
        }
    }return null
};
Fe.Dom.getStyle=function(A,B){
    return Fe.css(A,B)
};
Fe.Dom.getOwnerDocument=function(A){
    return A.nodeType==9?A:A.ownerDocument||A.document
};
Fe.isGecko=(navigator.userAgent.indexOf("Gecko")>-1&&navigator.userAgent.indexOf("KHTML")==-1&&/rv\:(\d+(\.\d+)?)/.test(navigator.userAgent))?RegExp.$1:0;Fe.isWebkit=(navigator.userAgent.indexOf("KHTML")>-1&&/AppleWebKit\/([^\s]*)/.test(navigator.userAgent))?RegExp.$1:0;Fe.isStrict=(document.compatMode=="CSS1Compat");Fe.Dom.getOffset=function(H){
    var B=Fe.Dom.getOwnerDocument(H);var A=Fe.isGecko>0&&B.getBoxObjectFor&&Fe.Dom.getStyle(H,"position")=="absolute"&&(H.style.top===""||H.style.left==="");var C={
        left:0,
        top:0
    };var E=(Fe.isIE&&!Fe.isStrict)?B.body:B.documentElement;if(H==E){
        return C
    }var F=null;var Q;if(H.getBoundingClientRect){
        Q=H.getBoundingClientRect();C.left=Q.left+Math.max(B.documentElement.scrollLeft,B.body.scrollLeft);C.top=Q.top+Math.max(B.documentElement.scrollTop,B.body.scrollTop);C.left-=B.documentElement.clientLeft;C.top-=B.documentElement.clientTop;if(Fe.isIE&&!Fe.isStrict){
            C.left-=2;C.top-=2
        }
    }else{
        if(B.getBoxObjectFor&&!A){
            Q=B.getBoxObjectFor(H);var D=B.getBoxObjectFor(E);C.left=Q.screenX-D.screenX;C.top=Q.screenY-D.screenY
        }else{
            F=H;do{
                C.left+=F.offsetLeft;C.top+=F.offsetTop;if(Fe.isWebkit>0&&Fe.Dom.getStyle(F,"position")=="fixed"){
                    C.left+=B.body.scrollLeft;C.top+=B.body.scrollTop;break
                }F=F.offsetParent
            }while(F&&F!=H);if(Fe.isOpera>0||(Fe.isWebkit>0&&Fe.Dom.getStyle(H,"position")=="absolute")){
                C.top-=B.body.offsetTop
            }F=H.offsetParent;while(F&&F!=B.body){
                C.left-=F.scrollLeft;if(!Fe.isOpera||F.tagName!="TR"){
                    C.top-=F.scrollTop
                }F=F.offsetParent
            }
        }
    }return C
};

Fe.Ajax=function(A){
    this.url="";this.data="";this.async=true;this.duration=-1;this.overtime=false;this.username="";this.password="";this.method="GET";if(typeof A=="object"&&A){
        for(var B in A){
            this[B]=A[B]
        }
    }
};

(function(){
    Fe.Ajax.prototype.request=function(F,Q){
        var E=this,J=A(),D=J.xhr;J.active=true;E.url=F;if(typeof Q=="string"&&Q){
            E.data=Q
        }if(typeof E.onexecute=="function"){
            E.onexecute(D)
        }try{
            if(!E.username){
                D.open(E.method,E.url,E.async)
            }else{
                D.open(E.method,E.url,E.async,E.username,E.password)
            }if(E.async){
                D.onreadystatechange=K
            }if(E.method.toUpperCase()=="POST"){
                D.setRequestHeader("Content-Type","application/x-www-form-urlencoded")
            }E.beginTime=new Date().getTime();if(E.duration>0){
                I()
            }D.send(E.data)
        }catch(H){
            if(typeof E.onerror=="function"){
                E.onerror(H)
            }
        }if(!E.async){
            K()
        }function K(){
            if(D.readyState==4){
                try{
                    D.status
                }catch(L){
                    if(typeof E.ondisconnect=="function"){
                        E.ondisconnect(D)
                    }J.active=false;return
                }E.duration=-1;if(!E.overtime){
                    if(typeof E["on"+D.status]=="function"){
                        E["on"+D.status](D)
                    }if(D.status==200&&D.statusText.toLowerCase()=="ok"){
                        if(typeof E.onsuccess=="function"){
                            E.onsuccess(D)
                        }
                    }else{
                        if(typeof E.onfailure=="function"){
                            E.onfailure(D)
                        }
                    }
                }J.active=false;D.onreadystatechange=function(){}
            }
        }function I(){
            if(E.duration==-1){
                return
            }if(new Date().getTime()-E.beginTime>E.duration){
                E.duration=-1;try{
                    D.abort()
                }catch(L){}E.overtime=true;J.active=false;if(typeof E.ontimeout=="function"){
                    E.ontimeout(D)
                }
            }setTimeout(function(){
                I()
            },10)
        }
    };var B=[];function A(){
        var D=B;for(var F=null,E=0;E<D.length;E++){
            F=D[E];if(!F.active){
                break
            }
        }if(E>=D.length){
            F={
                active:false,
                xhr:C()
            };D[D.length]=F
        }return F
    }function C(){
        if(window.XMLHttpRequest){
            return new XMLHttpRequest()
        }else{
            if(window.ActiveXObject){
                var D=["MSXML2.XMLHttp.6.0","MSXML2.XMLHttp.3.0","MSXML2.XMLHttp.5.0","MSXML2.XMLHttp.4.0","Msxml2.XMLHTTP","MSXML.XMLHttp","Microsoft.XMLHTTP"];for(var F=0;D[F];F++){
                    try{
                        return new ActiveXObject(D[F])
                    }catch(E){}
                }throw new Error("Your browser do not support XMLHttp")
            }
        }
    }
})();

Fe.Ajax.request=function(A,B,D){
    if(typeof B=="object"&&B){
        D=B;B=null
    }else{
        if(typeof B=="function"){
            D=D||{};D.onsuccess=B;B=null
        }
    }var C=new Fe.Ajax(D);C.request(A,B);return C
};
Fe.Ajax.get=function(B,A){
    return this.request(B,A)
};
Fe.Ajax.post=function(C,A,B){
    return this.request(C,A,{
        method:"POST",
        onsuccess:B
    })
};
Fe.trim=function(A){
    return A.replace(/(^[\s\t\xa0\u3000]+)|([\u3000\xa0\s\t]+$)/g,"")
};
Fe.Q=function(A,S,H){
    if(typeof A!="string"||A.length<=0){
        return null
    }var E=[],H=(typeof H=="string"&&H.length>0)?H.toLowerCase():null,I=(Fe.G(S)||document);if(I.getElementsByClassName){
        Fe.each(I.getElementsByClassName(A),function(J){
            if(H!==null){
                if(J.tagName.toLowerCase()==H){
                    E[E.length]=J
                }
            }else{
                E[E.length]=J
            }
        })
    }else{
        A=A.replace(/\-/g,"\\-");var F=new RegExp("(^|\\s{1,})"+Fe.trim(A)+"(\\s{1,}|$)"),C=(H===null)?(I.all?I.all:I.getElementsByTagName("*")):I.getElementsByTagName(H),B=C.length,D=B;while(B--){
            if(F.test(C[D-B-1].className)){
                E[E.length]=C[D-B-1]
            }
        }
    }return E
};
Fe.String={};
Fe.String.parseQuery=function(F,H){
    var I=new RegExp("(^|&|\\?|#)"+H+"=([^&]*)(&|$)","i");var E=F.match(I);if(E){
        return E[2]
    }return null
};
Fe.Ajax.sio=function(M,I){
    if(!M||typeof M!="string"){
        throw new Error("invalid url parameter!")
    }var J=document.createElement("SCRIPT");var K=Fe.String.parseQuery(M,"callback");if(K===null){
        J.onreadystatechange=J.onload=function(){
            if(J.readyState&&J.readyState!="loaded"&&J.readyState!="complete"){
                return
            }try{
                I()
            }finally{
                if(J.parentNode){
                    J.parentNode.removeChild(J)
                }J.onreadystatechange=null;J.onload=null;J=null
            }
        }
    }else{
        var N="CB"+Math.floor(Math.random()*2147483648).toString(36);M=M.replace(/(&|\?)callback=([^&]*)(&|$)/,"callback="+N);window[N]=function(){
            try{
                var A=(I||window[K]);A.apply(null,arguments)
            }finally{
                if(J.parentNode){
                    J.parentNode.removeChild(J)
                }J=null;window[N]=null
            }
        }
    }
    
    J.src=M;
    J.type="text/javascript";
    var L=document.getElementsByTagName("HEAD")[0];
    if(!L){
        var H=document.getElementsByTagName("body")[0];L=document.createElement("head");H.parentNode.insertBefore(L,H)
    }
    L.insertBefore(J,L.firstChild)
};
String.prototype.trim=function(){
    return this.replace(/(^[\s\t\xa0\u3000]+)|([\u3000\xa0\s\t]+$)/g,"")
};
String.prototype.byteLength=function(){
    return this.replace(/[^\u0000-\u007f]/g,"\u0061\u0061").length
};
String.prototype.format=function(){
    if(arguments.length==0){
        return this
    }for(var D=this,C=0;C<arguments.length;C++){
        D=D.replace(new RegExp("\\$"+C+"\\$","g"),arguments[C])
    }return D
};
String.prototype.subByte=function(H,I){
    if(this.byteLength()<=H){
        return this
    }for(var K=Math.floor((H=H-2)/2),F=this.length;K<F;K++){
        var J=this.substring(0,K);if(J.byteLength()>=H){
            return J+(I!=undefined?I:"...")
        }
    }return this
};
    
if(![].push){
    Array.prototype.push=function(){
        for(var B=0;B<arguments.length;B++){
            this[this.length]=arguments[B]
        }return this.length
    }
}

if(![].pop){
    Array.prototype.pop=function(){
        var B=this[this.length-1];this.length--;return B
    }
}

if(typeof (HTMLElement)!="undefined"&&!window.opera){
    HTMLElement.prototype.__defineGetter__("innerText",function(){
        return this.textContent
    });HTMLElement.prototype.__defineSetter__("innerText",function(B){
        this.textContent=B
    })
}
function bind(E,F){
    if(arguments<=1){
        return E
    }var D=Array.prototype.slice.call(arguments,2);if(D.length>0){
        return function(){
            E.apply(F,D.concat(Array.prototype.slice.call(arguments)))
        }
    }return function(){
        E.apply(F,arguments)
    }
}


function G(B){
    return Fe.G(B)
}