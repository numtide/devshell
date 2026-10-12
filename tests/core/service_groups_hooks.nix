{
  pkgs,
  devshell,
  runTest,
}:
let
  hookBeforeStart = pkgs.writeShellScript "hook-before-start" ''
    echo "BEFORE_START_EXECUTED" > "$PRJ_DATA_DIR/hook_before_start.log"
  '';
  hookAfterStart = pkgs.writeShellScript "hook-after-start" ''
    echo "AFTER_START_EXECUTED" > "$PRJ_DATA_DIR/hook_after_start.log"
  '';
  hookBeforeStop = pkgs.writeShellScript "hook-before-stop" ''
    echo "BEFORE_STOP_EXECUTED" > "$PRJ_DATA_DIR/hook_before_stop.log"
  '';
  hookAfterStop = pkgs.writeShellScript "hook-after-stop" ''
    echo "AFTER_STOP_EXECUTED" > "$PRJ_DATA_DIR/hook_after_stop.log"
  '';
  dummyService = pkgs.writeShellScript "dummy-service" ''
    while true; do sleep 1; done
  '';

  shell = devshell.mkShell {
    devshell.name = "service-groups-hooks-test";
    serviceGroups.test = {
      description = "Test service group";
      beforeStart = "${hookBeforeStart}";
      afterStart = "${hookAfterStart}";
      beforeStop = "${hookBeforeStop}";
      afterStop = "${hookAfterStop}";
      services.dummy = { command = "${dummyService}"; };
    };
  };
in
{
  service-groups-hooks-test = runTest "service-groups-hooks" { } ''
    # Load the devshell
    source ${shell}/env.bash

    # Start the service group
    test:start &
    START_PID=$!

    # Give it a moment to start
    sleep 2

    # Check that beforeStart hook was executed
    if [ ! -f "$PRJ_DATA_DIR/hook_before_start.log" ]; then
      echo "ERROR: beforeStart hook was not executed"
      exit 1
    fi

    if [ "$(cat "$PRJ_DATA_DIR/hook_before_start.log")" != "BEFORE_START_EXECUTED" ]; then
      echo "ERROR: beforeStart hook did not execute correctly"
      exit 1
    fi

    # Check that afterStart hook was executed
    if [ ! -f "$PRJ_DATA_DIR/hook_after_start.log" ]; then
      echo "ERROR: afterStart hook was not executed"
      exit 1
    fi

    if [ "$(cat "$PRJ_DATA_DIR/hook_after_start.log")" != "AFTER_START_EXECUTED" ]; then
      echo "ERROR: afterStart hook did not execute correctly"
      exit 1
    fi

    # Stop the service group
    test:stop

    # Give it a moment to stop
    sleep 2

    # Check that beforeStop hook was executed
    if [ ! -f "$PRJ_DATA_DIR/hook_before_stop.log" ]; then
      echo "ERROR: beforeStop hook was not executed"
      exit 1
    fi

    if [ "$(cat "$PRJ_DATA_DIR/hook_before_stop.log")" != "BEFORE_STOP_EXECUTED" ]; then
      echo "ERROR: beforeStop hook did not execute correctly"
      exit 1
    fi

    # Check that afterStop hook was executed
    if [ ! -f "$PRJ_DATA_DIR/hook_after_stop.log" ]; then
      echo "ERROR: afterStop hook was not executed"
      exit 1
    fi

    if [ "$(cat "$PRJ_DATA_DIR/hook_after_stop.log")" != "AFTER_STOP_EXECUTED" ]; then
      echo "ERROR: afterStop hook did not execute correctly"
      exit 1
    fi

    # Clean up
    kill $START_PID 2>/dev/null || true
    wait $START_PID 2>/dev/null || true
  '';
}
