#!/usr/bin/env bash
#
# scan.sh [ --remediate ]
#
# Run an OpenSCAP scan optionally using a local or remotely stored tailoring file
# https://www.open-scap.org/security-policies/customization/
#
echoerr() { cat <<< "$@" 1>&2; }
install_check() { if ! hash aws 2> /dev/null ; then echo "aws cli not installed. Aborting ..." ; exit 1 ; fi }

REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | rev | cut -c 2- | rev)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

#
# Read the system settings
#
source ${REPORT_DIR}/etc/openscap-aws.conf

#
# Conduct a scan and get the score
#
RESULTS_DATA_FILE=scan-xccdf-results.xml
rm -f "${REPORT_DIR}/${RESULTS_DATA_FILE}"

oscap xccdf eval --fetch-remote-resources "$@" \
    --profile $PROFILE \
    --results "${REPORT_DIR}/${RESULTS_DATA_FILE}" \
    --report "${REPORT_DIR}/$(hostname)-scap-report-$(date +%Y%m%d).html" \
    --tailoring-file "${REPORT_DIR}/etc/aws-cloud-tailored.xml" \
    "${REPORT_DIR}/etc/scap-security-guide-${SCAP_VERSION}/${DATA_STREAM}"

SCORE=$(xmlstarlet sel -t -m "//_:Benchmark/_:TestResult" -v "_:score" "${REPORT_DIR}/${RESULTS_DATA_FILE}")
SCORE=$(echo "${SCORE} / 1" | bc) # truncate float

#
# Publish score metric to CloudWatch and possibly report a failure to SNS
#
install_check

aws cloudwatch put-metric-data \
    --namespace "$CLOUDWATCH_METRIC_NAME" \
    --metric-name $CLOUDWATCH_METRIC_DIMENSION \
    --unit Count \
    --value $SCORE \
    --dimensions InstanceId=$INSTANCE_ID \
    --region $REGION

if [ $SCORE -lt $MIN_SCORE ] && [ ! -z SNS_TOPIC_ARN ] ; then
    FINDINGS=$(xmlstarlet sel -t -m "//_:Benchmark/_:TestResult/_:rule-result[_:result='fail']" -v "./@idref" -n ${REPORT_DIR}/${RESULTS_DATA_FILE})
    echoerr $(echo -e "Instance ${INSTANCE_ID} has the following findings:\n\n${FINDINGS}")
    aws sns publish \
        --topic-arn $SNS_TOPIC_ARN \
        --region $REGION \
        --subject "OpenSCAP Scan Failure - ${INSTANCE_ID}" \
        --message "$(echo -e Instance ${INSTANCE_ID} has the following findings:\\n\\n${FINDINGS})"
fi