function timestamp() {
    const d = new Date();
    return `${d.getDate()}.${d.getMonth()}.${d.getFullYear()} ${d.getHours()}:${d.getMinutes()}:${d.getSeconds()}`;
}

function message(text) {
    return `[${timestamp()}] ${text}`;
}

function info(text) {
    console.log(message(text));
}

function warning(text) {
    console.warn(message(text));
}

function error(text) {
    console.error(message(text));
}

module.exports = {
    info,
    warning,
    error
};
