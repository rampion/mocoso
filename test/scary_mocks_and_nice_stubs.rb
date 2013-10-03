require 'cutest'
require_relative '../lib/mocoso'

class Subject
  def foo; 'foo'; end
  def bar; 'bar'; end
  def baz(value); value; end

  def self.foo
    'foo'
  end
end

include Mocoso

setup do
  Subject.new
end

test 'raises error if object not respond to the given method' do |subject|
  assert_raise { stub(subject, nan: nil, undefined: nil) }
end

test 'stubs methods and return new values' do |subject|
  before_foo = subject.foo
  before_bar = subject.bar

  stub subject, foo: 'new foo', bar: 'new bar'

  assert subject.foo != before_foo
  assert subject.bar != before_bar
end

test 'stubs method with a callable object' do |subject|
  before = subject.foo

  stub subject, foo: ->(a) { "new #{a}" }

  assert subject.foo('foo') != before
end

test 'stubs method without side effects if a block is given' do
  before = Subject.foo

  stub Subject, foo: 'new foo' do
    assert before != Subject.foo
  end

  assert_equal before, Subject.foo
end

test 'succeeds if expectations are met' do |subject|
  expect subject, :baz, with: ['value'], return: 'result'

  assert_equal 'result', subject.baz('value')
end

test 'raises an error if expectation are not met' do |subject|
  expect subject, :baz, with: ['value'], return: 'result'

  assert_raise(Mocoso::ExpectationError) { subject.baz('another') }
end

test 'expectation without side effects if a block is given' do |subject|
  expect subject, :baz, with: ['value'], return: 'mocked' do
    assert_equal 'mocked', subject.baz('value')
  end

  assert_equal 'original', subject.baz('original')
end

test 'expectation without arguments' do |subject|
  expect subject, :foo, return: 'new foo'

  assert_equal 'new foo', subject.foo
end

test 'expectation with multiple arguments' do |subject|
  expect subject, :foo, with: ['new foo', { optional: true }], return: 'new foo'

  assert_equal 'new foo', subject.foo('new foo', optional: true)
end

test 'unstub removes specified stubbed methods' do |subject|
  before_foo = subject.foo
  before_bar = subject.bar

  stub subject, foo: 'new foo', bar: 'new bar', baz: 'new baz'

  assert before_foo != subject.foo
  assert before_bar != subject.bar

  unstub subject, [:foo, :bar]

  assert_equal before_foo, subject.foo
  assert_equal before_bar, subject.bar
  assert_equal 'new baz', subject.baz
end

test 'unstub removes specified expectations' do
  before = Subject.foo

  expect Subject, :foo, return: 'new foo'

  assert_equal 'new foo', Subject.foo

  unstub Subject, [:foo]

  assert_equal before, Subject.foo
end
