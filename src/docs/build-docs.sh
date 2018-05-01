#!/usr/bin/env bash

cd /documents/asciidoc

cp -R images stylesheets /docs-output

asciidoctor docs.adoc --destination-dir /docs-output