if [ -r /keybase/team/mongoperf/secrets/prod-env.sh ]; then
    source /keybase/team/mongoperf/secrets/prod-env.sh
fi

if [[ "$PERF_DSI_ENV" == "PROD" ]]; then
    export DSI_MONGO_URI="$PERF_PROD_DSI_MONGO_URI"
fi
