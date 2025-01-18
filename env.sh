#!/bin/sh

# env.sh

# Change the contents of this output to get the environment variables
# of interest. The output must be valid JSON, with strings for both
# keys and values.
cat <<EOF
{
  "region": "$AWS_REGION",
  "az": "$AWS_AZ",
  "work_env": "$WORK_ENV"
}
EOF