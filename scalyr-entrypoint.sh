#!/usr/bin/env bash

. /usr/local/bin/mo || exit 1

echo "Installing and configuring Scalyr Agent"

wget -q https://www.scalyr.com/scalyr-repo/stable/latest/scalyr-agent-${SCALYR_VERSION}.tar.gz || exit 1
tar --no-same-owner -zxf scalyr-agent-${SCALYR_VERSION}.tar.gz || exit 1
mv scalyr-agent-${SCALYR_VERSION} /usr/local/scalyr-agent-2 || exit 1

/usr/local/scalyr-agent-2/bin/scalyr-agent-2-config --set-key "${SCALYR_APIKEY}" --set-scalyr-server "${SCALYR_SERVER}" || exit 1

cat <<EOF > /usr/local/scalyr-agent-2/config/agent.d/noimplicit.json || exit 1
{
    implicit_metric_monitor : false
}
EOF

cat <<EOF > /usr/local/scalyr-agent-2/config/agent.d/graphite.json || exit 1
{
  "monitors": [
    {
      "module": "scalyr_agent.builtin_monitors.graphite_monitor"
    }
  ]
}
EOF

/usr/local/scalyr-agent-2/bin/scalyr-agent-2 start || exit 1

echo "Configuring jmxtrans"

IFS='|' read -r -a JMX_QUERIES <<< "${JMX_QUERIES}"

GET_OBJ() {
  moShow "${moCurrent}" | cut -d ";" -f 1 | cut -d "@" -f 1
}

GET_ATTR() {
  ATTRS=""
  IFS=', ' read -r -a args <<< "$(moShow "${moCurrent}" | cut -d ";" -f 2)"
  for ARG in "${args[@]}"
  do
    ATTRS="${ATTRS}\"${ARG}\","
  done
  echo "[${ATTRS/%,/}]"
}

GET_RESULTALIAS() {
  OBJ=$(moShow "${moCurrent}" | cut -d ";" -f 1 | cut -d "@" -f 1)
  RESALIAS=$(moShow "${moCurrent}" | cut -d ";" -f 1 | cut -d "@" -f 2)

  if [ "$OBJ" != "$RESALIAS" ]
  then
    echo "\"resultAlias\": \"$RESALIAS\","
  fi
}

COMMA_IF_NOT_FIRST() {
    [[ "${moCurrent#*.}" != "0" ]] && echo ","
}

cat /jmxtrans.json.mustache | mo > /var/lib/jmxtrans/localhost.json || exit 1

echo "Starting jmxtrans"

bash /docker-entrypoint.sh start-without-jmx || exit 1
