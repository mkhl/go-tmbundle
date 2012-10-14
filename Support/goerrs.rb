#!/usr/bin/env ruby

require "#{ENV['TM_BUNDLE_SUPPORT']}/Builder"
require "#{ENV['TM_SUPPORT_PATH']}/lib/escape"
require "pathname"

module Go
  def self.normalize_file(file)
    return nil  if file == 'untitled'
    return file if Pathname.new(file).absolute?
    base = ENV['TM_PROJECT_DIRECTORY'] || ENV['TM_DIRECTORY'] || Dir.getwd
    File.join(base, file)
  end

  def self.href(file, line, column)
    file = normalize_file(file)
    parts = []
    parts << "line=#{line}"  if line
    parts << "column=#{column}"  if column
    parts << "url=file://#{e_url(file)}"  if file
    "txmt://open?#{parts.join("&")}"
  end

  def self.link_errs(str, type)
    return  unless type == :err
    xml = Builder::XmlMarkup.new
    str.gsub! /^((.+?):(\d+)(?::(\d+))?):\s+(.+)$/ do
      addr, file, line, col, msg = $1, $2, $3, $4, $5
      xml.a("#{htmlize(File.basename(addr))}", :href => href(file, line, col))
      xml.text(': ')
      xml.span(htmlize(msg), :class => "err")
      xml.br
    end
  end
end
