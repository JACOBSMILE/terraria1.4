#!/bin/sh
while true
do
    sleep ${TERRARIA_AUTOSAVE_INTERVAL}m
    inject "save"
    inject "say The World has been saved."
done