var Just = _elm_lang$core$Maybe$Just
var Nothing = _elm_lang$core$Maybe$Nothing
var Task = _elm_lang$core$Native_Scheduler;
var Tuple0 = _elm_lang$core$Native_Utils.Tuple0;

var _javabin$switcharoo$Native_LocalStorage = (function() {
    var getItem = function(item) {
        var val = localStorage.getItem(item);
        return !!val ? Just(val) : Nothing;
    };

    var setItem = function(item) {
        return function(val) {
            localStorage.setItem(item, JSON.stringify(val));
            return Task.succeed(Tuple0);
        };
    };

    var removeItem = function(item) {
        localStorage.removeItem(item);
        return Task.succeed(Tuple0);
    };

    var clear = function() {
        localStorage.clear();
        return Task.succeed(Tuple0);
    };

    return {
        getItem : getItem,
        setItem : setItem,
        removeItem : removeItem,
        clear : clear
    };
})();
