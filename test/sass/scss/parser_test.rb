#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/../../test_helper'
require 'sass/engine'

class ScssParserTest < Test::Unit::TestCase

  def test_basic_scss
    assert_parses <<SCSS
selector {
  property: value;
  property2: value; }
SCSS

    assert_equal <<CSS, render('sel{p:v}')
sel {
  p: v; }
CSS
  end

  def test_cdo_and_cdc_ignored_at_toplevel
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz; }

bar {
  bar: baz; }

baz {
  bar: baz; }
CSS
foo {bar: baz}
<!--
bar {bar: baz}
-->
baz {bar: baz}
SCSS
  end

  ## Declarations

  def test_vendor_properties
    assert_parses <<SCSS
foo {
  -moz-foo-bar: blat;
  -o-flat-blang: wibble; }
SCSS
  end

  def test_empty_declarations
    assert_equal <<CSS, render(<<SCSS)
foo {
  bar: baz; }
CSS
foo {;;;;
  bar: baz;;;;
  ;;}
SCSS
  end

  def test_basic_property_types
    assert_parses <<SCSS
foo {
  a: 2;
  b: 2.3em;
  c: 50%;
  d: "fraz bran";
  e: flanny-blanny-blan;
  f: url(http://sass-lang.com);
  g: U+ffa?;
  h: #abc; }
SCSS
  end

  def test_functions
    assert_parses <<SCSS
foo {
  a: foo-bar(12);
  b: -foo-bar-baz(13, 14 15); }
SCSS
  end

  def test_unary_minus
    assert_parses <<SCSS
foo {
  a: -2;
  b: -2.3em;
  c: -50%;
  d: -foo(bar baz); }
SCSS
  end

  def test_operators
    assert_parses <<SCSS
foo {
  a: foo bar baz;
  b: foo, #abc, -12;
  c: 1px/2px/-3px;
  d: foo bar, baz/bang; }
SCSS
  end

  def test_important
    assert_parses <<SCSS
foo {
  a: foo !important;
  b: foo bar !important;
  b: foo, bar !important; }
SCSS
  end

  ## Directives

  def test_charset_directive
    assert_parses '@charset "utf-8";'
  end

  def test_namespace_directive
    assert_parses '@namespace "http://www.w3.org/Profiles/xhtml1-strict";'
    assert_parses '@namespace url(http://www.w3.org/Profiles/xhtml1-strict);'
    assert_parses '@namespace html url("http://www.w3.org/Profiles/xhtml1-strict");'
  end

  def test_media_directive
    assert_parses <<SCSS
@media all {
  rule1 {
    prop: val; }

  rule2 {
    prop: val; } }
SCSS
    assert_parses <<SCSS
@media screen, print {
  rule1 {
    prop: val; }

  rule2 {
    prop: val; } }
SCSS
  end

  def test_page_directive
    assert_parses <<SCSS
@page {
  prop1: val;
  prop2: val; }
SCSS
    assert_parses <<SCSS
@page flap {
  prop1: val;
  prop2: val; }
SCSS
    assert_parses <<SCSS
@page :first {
  prop1: val;
  prop2: val; }
SCSS
    assert_parses <<SCSS
@page flap:first {
  prop1: val;
  prop2: val; }
SCSS
  end

  def test_blockless_directive_without_semicolon
    assert_equal "@charset \"utf-8\";\n", render('@charset "utf-8"')
  end

  def test_directive_with_lots_of_whitespace
    assert_equal "@charset \"utf-16\";\n", render('@charset    "utf-16"  ;')
  end

  def test_empty_blockless_directive
    assert_parses "@foo;"
  end

  def test_multiple_blockless_directives
    assert_parses <<SCSS
@foo bar;
@bar baz;
SCSS
  end

  # TODO: Make this work.
  #   Currently we check whether a directive has children
  #   to determine whether to use {} or ;.
  #
  # def test_empty_block_directive
  #   assert_parses "@foo {}"
  # end

  def test_multiple_block_directives
    assert_parses <<SCSS
@foo bar {
  a: b; }

@bar baz {
  c: d; }
SCSS
  end

  def test_block_directive_with_rule_and_property
    assert_parses <<SCSS
@foo {
  rule {
    a: b; }

  a: b; }
SCSS
  end

  def test_block_directive_with_semicolon
    assert_equal <<CSS, render(<<SCSS)
@foo {
  a: b; }

@bar {
  a: b; }
CSS
@foo {a:b};
@bar {a:b};
SCSS
  end

  ## Selectors

  # Taken from http://www.w3.org/TR/css3-selectors/#selectors
  def test_summarized_selectors
    assert_selector_parses('*')
    assert_selector_parses('E')
    assert_selector_parses('E[foo]')
    assert_selector_parses('E[foo="bar"]')
    assert_selector_parses('E[foo~="bar"]')
    assert_selector_parses('E[foo^="bar"]')
    assert_selector_parses('E[foo$="bar"]')
    assert_selector_parses('E[foo*="bar"]')
    assert_selector_parses('E[foo|="en"]')
    assert_selector_parses('E:root')
    assert_selector_parses('E:nth-child(n)')
    assert_selector_parses('E:nth-last-child(n)')
    assert_selector_parses('E:nth-of-type(n)')
    assert_selector_parses('E:nth-last-of-type(n)')
    assert_selector_parses('E:first-child')
    assert_selector_parses('E:last-child')
    assert_selector_parses('E:first-of-type')
    assert_selector_parses('E:last-of-type')
    assert_selector_parses('E:only-child')
    assert_selector_parses('E:only-of-type')
    assert_selector_parses('E:empty')
    assert_selector_parses('E:link')
    assert_selector_parses('E:visited')
    assert_selector_parses('E:active')
    assert_selector_parses('E:hover')
    assert_selector_parses('E:focus')
    assert_selector_parses('E:target')
    assert_selector_parses('E:lang(fr)')
    assert_selector_parses('E:enabled')
    assert_selector_parses('E:disabled')
    assert_selector_parses('E:checked')
    assert_selector_parses('E::first-line')
    assert_selector_parses('E::first-letter')
    assert_selector_parses('E::before')
    assert_selector_parses('E::after')
    assert_selector_parses('E.warning')
    assert_selector_parses('E#myid')
    assert_selector_parses('E:not(s)')
    assert_selector_parses('E F')
    assert_selector_parses('E > F')
    assert_selector_parses('E + F')
    assert_selector_parses('E ~ F')
  end

  # Taken from http://www.w3.org/TR/css3-selectors/#selectors,
  # but without the element names
  def test_lonely_selectors
    assert_selector_parses('[foo]')
    assert_selector_parses('[foo="bar"]')
    assert_selector_parses('[foo~="bar"]')
    assert_selector_parses('[foo^="bar"]')
    assert_selector_parses('[foo$="bar"]')
    assert_selector_parses('[foo*="bar"]')
    assert_selector_parses('[foo|="en"]')
    assert_selector_parses(':root')
    assert_selector_parses(':nth-child(n)')
    assert_selector_parses(':nth-last-child(n)')
    assert_selector_parses(':nth-of-type(n)')
    assert_selector_parses(':nth-last-of-type(n)')
    assert_selector_parses(':first-child')
    assert_selector_parses(':last-child')
    assert_selector_parses(':first-of-type')
    assert_selector_parses(':last-of-type')
    assert_selector_parses(':only-child')
    assert_selector_parses(':only-of-type')
    assert_selector_parses(':empty')
    assert_selector_parses(':link')
    assert_selector_parses(':visited')
    assert_selector_parses(':active')
    assert_selector_parses(':hover')
    assert_selector_parses(':focus')
    assert_selector_parses(':target')
    assert_selector_parses(':lang(fr)')
    assert_selector_parses(':enabled')
    assert_selector_parses(':disabled')
    assert_selector_parses(':checked')
    assert_selector_parses('::first-line')
    assert_selector_parses('::first-letter')
    assert_selector_parses('::before')
    assert_selector_parses('::after')
    assert_selector_parses('.warning')
    assert_selector_parses('#myid')
    assert_selector_parses(':not(s)')
  end

  def test_attribute_selectors_with_identifiers
    assert_selector_parses('[foo~=bar]')
    assert_selector_parses('[foo^=bar]')
    assert_selector_parses('[foo$=bar]')
    assert_selector_parses('[foo*=bar]')
    assert_selector_parses('[foo|=en]')
  end

  def test_nth_selectors
    assert_selector_parses(':nth-child(-n)')
    assert_selector_parses(':nth-child(+n)')

    assert_selector_parses(':nth-child(even)')
    assert_selector_parses(':nth-child(odd)')

    assert_selector_parses(':nth-child(50)')
    assert_selector_parses(':nth-child(-50)')
    assert_selector_parses(':nth-child(+50)')

    assert_selector_parses(':nth-child(2n+3)')
    assert_selector_parses(':nth-child(2n-3)')
    assert_selector_parses(':nth-child(+2n-3)')
    assert_selector_parses(':nth-child(-2n+3)')
    assert_selector_parses(':nth-child(-2n+ 3)')
    assert_selector_parses(':nth-child( 2n + 3 )')
  end

  def test_negation_selectors
    assert_selector_parses(':not(foo|bar)')
    assert_selector_parses(':not(*|bar)')

    assert_selector_parses(':not(foo|*)')
    assert_selector_parses(':not(*|*)')

    assert_selector_parses(':not(#blah)')
    assert_selector_parses(':not(.blah)')

    assert_selector_parses(':not([foo])')
    assert_selector_parses(':not([foo^="bar"])')
    assert_selector_parses(':not([baz|foo~="bar"])')

    assert_selector_parses(':not(:hover)')
    assert_selector_parses(':not(:nth-child(2n + 3))')
  end

  def test_namespaced_selectors
    assert_selector_parses('foo|E')
    assert_selector_parses('*|E')
    assert_selector_parses('foo|*')
    assert_selector_parses('*|*')
  end

  def test_namespaced_attribute_selectors
    assert_selector_parses('[foo|bar=baz]')
    assert_selector_parses('[*|bar=baz]')
    assert_selector_parses('[foo|bar|=baz]')
  end

  private

  def assert_valid_string(ident)
    assert_equal
  end

  def assert_selector_parses(selector)
    assert_parses <<SCSS
#{selector} {
  a: b; }
SCSS
  end

  def assert_parses(scss)
    assert_equal scss.rstrip, render(scss, munge_filename).rstrip
  end

  def render(scss, options = {})
    munge_filename options
    options[:syntax] ||= :scss
    Sass::Engine.new(scss, options).render
  end
end