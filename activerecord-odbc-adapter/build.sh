#!/bin/sh
#

gem uninstall activerecord-odbc-adapter
gem build activerecord-odbc-adapter
gem install activerecord-odbc-adapter-7.0.0.gem
