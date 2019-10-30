#!/bin/bash

# usage:
#  $1 - folder that holds configuration information in firesim-configs

# turn echo on and error on earliest command
set -ex

# get shared variables
SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
source $SCRIPT_DIR/defaults.sh

FMRSHL_CFG=$LOCAL_CHECKOUT_DIR/.circleci/firesim-configs/$1/firemarshal_config

WORKLOAD_NAME=$(sed -n '2p' $FMRSHL_CFG)
WORKLOAD_DIR=$REMOTE_AWS_MARSHAL_DIR/$(sed -n '1p' $FMRSHL_CFG)

cat <<EOF >> $LOCAL_CHECKOUT_DIR/firesim-$WORKLOAD_NAME-build.sh
#!/bin/bash

set -ex

# setup firesim to get toolchain
cd $REMOTE_AWS_FSIM_DIR
source sourceme-f1-manager.sh

cd $REMOTE_AWS_MARSHAL_DIR
./marshal -v build $WORKLOAD_DIR/$WORKLOAD_NAME.json
./marshal -v install $WORKLOAD_DIR/$WORKLOAD_NAME.json
EOF

# execute the script
chmod +x $LOCAL_CHECKOUT_DIR/firesim-$WORKLOAD_NAME-build.sh
run_script_aws $LOCAL_CHECKOUT_DIR/firesim-$WORKLOAD_NAME-build.sh

