<?

// Returns the default if the variable is either not provided, or empty.
function getParameterFrom($parameters, $name, $default = null) {
    if (array_key_exists($name, $parameters) && 
        (
            // string
            (is_string($parameters[$name]) && (strlen($parameters[$name]) > 0))
            ||
            // array
            (is_array($parameters[$name]) && (count($parameters[$name]) > 0))
        )) {
        return $parameters[$name];
    }
    return $default;
}

// Returns the value of a named GET variable.
// Returns the default if the variable is either not provided, or empty.
function getParameter($name, $default = null) {
    return getParameterFrom($_GET, $name, $default);
}

// Returns the value of a named POST variable.
// Returns the default if the variable is either not provided, or empty.
function getPOSTParameter($name, $default = null) {
    return getParameterFrom($_POST, $name, $default);
}

?>