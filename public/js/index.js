!function t(e,n,r){function o(a,i){if(!n[a]){if(!e[a]){var s="function"==typeof require&&require;if(!i&&s)return s(a,!0);if(c)return c(a,!0);var u=new Error("Cannot find module '"+a+"'");throw u.code="MODULE_NOT_FOUND",u}var l=n[a]={exports:{}};e[a][0].call(l.exports,function(t){var n=e[a][1][t];return o(n?n:t)},l,l.exports,t,e,n,r)}return n[a].exports}for(var c="function"==typeof require&&require,a=0;a<r.length;a++)o(r[a]);return o}({1:[function(t,e,n){$(function(){var e,n,r;return n=t("./sockets"),r=t("./templates"),$("#flashMessages").click(function(){return $(this).slideUp()}),$("#placeBidLink, #placeBidLinkFirst, #placeBidLinkMenu").click(function(){return r.rate.scope.rate="Bid",r.rate.render(),$("#placeRate").modal("show")}),$("#placeAskLink, #placeAskLinkFirst, #placeAskLinkMenu").click(function(){return r.rate.scope.rate="Ask",r.rate.render(),$("#placeRate").modal("show")}),$("#bidsTable, #asksTable").click("tr",function(){return $("#takeRate").modal("show")}),e=function(){return{currency:$("#rateCurrencySelector").val(),left:$("#rateAmountInput").val(),amount:$("#rateAmountInput").val(),part:$("#ratePartInput").val(),time:$("#rateTimePicker").data("DateTimePicker").date().format("x"),comment:$("#commentArea").val()}},$("#placeRateButton").click(function(){var t,o,c,a;return o="Bid"===r.rate.scope.rate,t=o?"bids":"asks",a=r[t],c=e(),a.scope.rates.push(c),a.render(),n[t].emit("place",c),$("#placeRate").modal("hide"),$("#rateForm").trigger("reset"),$("#rateTimePicker").data("DateTimePicker").date(moment().add(4,"hour"))}),$("#rateTimePicker").datetimepicker({format:"HH:mm",stepping:10,minDate:moment().add(30,"minutes"),maxDate:moment().add(1,"day"),defaultDate:moment().add(4,"hour")})})},{"./sockets":5,"./templates":8}],2:[function(t,e,n){var r,o,c,a=function(t,e){function n(){this.constructor=t}for(var r in e)i.call(e,r)&&(t[r]=e[r]);return n.prototype=e.prototype,t.prototype=new n,t.__super__=e.prototype,t},i={}.hasOwnProperty;o=t("./channel"),c=t("../templates"),r=function(t){function e(){e.__super__.constructor.call(this,"asks"),this.channel.emit("list"),this.channel.on("list",function(t){return console.log(t),c.asks.scope.rates=t,c.asks.render()}),this.channel.on("place",function(t){return console.log("place",t)})}return a(e,t),e}(o),e.exports=r},{"../templates":8,"./channel":4}],3:[function(t,e,n){var r,o,c,a=function(t,e){function n(){this.constructor=t}for(var r in e)i.call(e,r)&&(t[r]=e[r]);return n.prototype=e.prototype,t.prototype=new n,t.__super__=e.prototype,t},i={}.hasOwnProperty;o=t("./channel"),c=t("../templates"),r=function(t){function e(){e.__super__.constructor.call(this,"bids"),this.channel.emit("list"),this.channel.on("list",function(t){return c.bids.scope.rates=t,c.bids.render()}),this.channel.on("place",function(t){return console.log("place",t)})}return a(e,t),e}(o),e.exports=r},{"../templates":8,"./channel":4}],4:[function(t,e,n){var r;r=function(){function t(t){this.name=t,this.channel=io("localhost:9000/"+this.name,this.copts),this.channel.on("connecting",function(t){return function(){return t.registred++,t.channel.attempts=0,t.reload=setTimeout(function(){return t.showError(),setTimeout(function(){return window.location.reload()},5e3)},25e3)}}(this)),this.channel.on("connect",function(t){return function(){return clearTimeout(t.reload),t.registred--,t.registred?void 0:t.hideConnect()}}(this)),this.channel.on("connect_failed",function(t){return function(){return console.log("connect_failed"),t.showError()}}(this)),this.channel.on("reconnecting",function(t){return function(){return t.channel.attempts++,t.channel.attempts===t.copts["max reconnection attempts"]?t.showError():void 0}}(this)),this.channel.on("reconnect",function(t){return function(){return t.channel.attempts--,window.location.reload()}}(this)),this.channel.on("reconnect_failed",function(t){return function(){return console.log("reconnect_failed"),t.showError()}}(this)),this.channel.on("disconnect",function(t){return function(){return t.registred++,t.showConnect()}}(this)),this.channel.on("error",function(t){return function(){return t.showError()}}(this))}return t.prototype.copts={"connect timeout":5e3,"max reconnection attempts":4},t.prototype.registred=0,t.prototype.showConnect=function(){return console.log("connecting...")},t.prototype.hideConnect=function(){return console.log("connected")},t.prototype.showError=function(){return this.showConnect(),$("#connect_error").show()},t}(),e.exports=r},{}],5:[function(t,e,n){var r,o;o=t("./bids"),r=t("./asks"),n.bids=(new o).channel,n.asks=(new r).channel},{"./asks":2,"./bids":3}],6:[function(t,e,n){var r;r=soma.template.create($("#askPanel").get(0)),r.scope.timeFormat=function(t){return moment.unix(t).format("HH:mm")},r.scope.rates=[],r.render(),e.exports=r},{}],7:[function(t,e,n){var r;r=soma.template.create($("#bidPanel").get(0)),r.scope.timeFormat=function(t){return moment.unix(t).format("HH:mm")},r.scope.rates=[],r.render(),e.exports=r},{}],8:[function(t,e,n){n.bids=t("./bids"),n.asks=t("./asks"),n.rate=t("./rate")},{"./asks":6,"./bids":7,"./rate":9}],9:[function(t,e,n){var r;r=soma.template.create($("#placeRate").get(0)),e.exports=r},{}]},{},[1]);
//# sourceMappingURL=index.js.map