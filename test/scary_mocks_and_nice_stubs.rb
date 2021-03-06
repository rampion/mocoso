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

test 'raises error if block is not given' do |subject|
  assert_raise { stub(subject, foo: 'foo') }
end

test 'raises error if object not respond to the given method' do |subject|
  assert_raise(NameError) { stub(subject, :nan, nil) }
end

test 'stubbed method return new value' do |subject|
  before = subject.foo

  stub subject, :foo, 'new foo' do
    assert_equal 'new foo', subject.foo
  end

  assert_equal before, subject.foo
end

test 'stubs method with a callable object' do |subject|
  before = subject.foo

  stub subject, :foo, -> { 'new foo' } do
    assert_equal 'new foo', subject.foo
  end

  assert_equal before, subject.foo
end

test 'stubs method with a callable object that requires arguments' do |subject|
  before = subject.foo

  stub subject, :foo, ->(a) { "new #{a}" } do
    assert_equal 'new foo', subject.foo('foo')
  end

  assert_equal before, subject.foo
end

test 'succeeds if expectations are met' do |subject|
  expect subject, :baz, with: ['value'], returns: 'result' do
    assert_equal 'result', subject.baz('value')
  end

  assert_equal 'baz', subject.baz('baz')
end

test 'raises an error if expectation are not met' do |subject|
  expect subject, :baz, with: ['value'], returns: 'result' do
    assert_raise(Mocoso::ExpectationError) { subject.baz('another') }
  end
end

test 'expectation without with option defaults to empty array' do |subject|
  expect subject, :foo, returns: 'new foo' do
    assert_equal 'new foo', subject.foo
  end
end

test 'expectation with multiple arguments' do |subject|
  expect subject, :foo, with: ['new foo', { optional: true }], returns: 'new foo' do
    assert_equal 'new foo', subject.foo('new foo', optional: true)
  end
end

test 'raises error if stubbed method is never invoked' do |subject|
  assert_raise {
    stub subject, :foo, 'value' do
    end
  }
end

test 'can have a stub within a stub' do |subject|
  stub subject, :foo, 'outer' do
    stub subject, :foo, 'inner' do
      assert_equal 'inner', subject.foo
    end
    assert_equal 'outer', subject.foo
  end
end

test 'yields a hook to call the original method' do |subject|
  stub subject, :foo, 'outer' do |original|
    assert_equal 'outer', subject.foo
    assert_equal 'foo', original.call
  end
end
