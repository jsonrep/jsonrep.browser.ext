#!/usr/bin/env bash.origin.script

depend {
    "webext": "@com.github/pinf-to/to.pinf.org.mozilla.web-ext#s1"
}


function do_build {

    CALL_webext run {
        "manifest": {
            "name": "JSONrep",
            "description": "Render JSONrep annotated JSON documents on GitHub",
            "applications": {
                "gecko": {
                    "id": "browser-ext-com-github-0@jsonrep.org",
                    "strict_min_version": "42.0"
                }
            },
            "permissions": [
                "<all_urls>"
            ]
        },
        "routes": {
            "^/$": (javascript (API) >>>

                return function (req, res, next) {

                    res.end("Hello World");

                    if (process.env.BO_TEST_FLAG_DEV) return;

                    setTimeout(function () {
                        API.SERVER.stop();
                    }, 1000);
                };
            <<<)
        }
    }

}

function do_sign {

    pushd ".rt/github.com~pinf-to~to.pinf.org.mozilla.web-ext/extension.built" > /dev/null

        CALL_webext sign {
            "dist": "$__DIRNAME__/dist/jsonrep-com-github.xpi",
            "manifest": {
            }
        }

    popd > /dev/null
}


BO_parse_args "ARGS" "$@"


if [ "$ARGS_1" == "build" ]; then

    do_build

elif [ "$ARGS_1" == "sign" ]; then

    if [ "$ARGS_OPT_dev" == "true" ]; then
        export BO_TEST_FLAG_DEV=1
    fi

    if [ "$ARGS_OPT_skip_build" != "true" ]; then
        do_build
    fi

    if [ "$ARGS_OPT_dev" == "true" ]; then
        echo "Not signing. Exiting due to --dev"
        exit 0
    fi

    do_sign
fi
