require 'spec_helper'

describe 'consul_template::hcl' do

  it 'handles nil' do
    is_expected.to run.with_params({ 'key' => nil }).and_return("key = null\n")
  end
  it 'handles :undef' do
    is_expected.to run.with_params({ 'key' => :undef }).and_return("key = null\n")
  end
  it 'handles true' do
    is_expected.to run.with_params({ 'key' => true }).and_return("key = true\n")
  end
  it 'handles false' do
    is_expected.to run.with_params({ 'key' => false }).and_return("key = false\n")
  end
  it 'handles positive integer' do
    is_expected.to run.with_params({ 'key' => 1 }).and_return("key = 1\n")
  end
  it 'handles negative integer' do
    is_expected.to run.with_params({ 'key' => -1 }).and_return("key = -1\n")
  end
  it 'handles positive float' do
    is_expected.to run.with_params({ 'key' => 1.1 }).and_return("key = 1.1\n")
  end
  it 'handles negative float' do
    is_expected.to run.with_params({ 'key' => -1.1 }).and_return("key = -1.1\n")
  end
  it 'handles integer in a string' do
    is_expected.to run.with_params({ 'key' => '1' }).and_return(%Q{key = "1"\n})
  end
  it 'handles negative integer in a string' do
    is_expected.to run.with_params({ 'key' => '-1' }).and_return(%Q{key = "-1"\n})
  end
  it 'handles simple string' do
    is_expected.to run.with_params({ 'key' => 'aString' }).and_return(%Q{key = "aString"\n})
  end
  it 'handles quoted string' do
    is_expected.to run.with_params({ 'key' => '"aString"' }).and_return(%Q{key = "\\"aString\\""\n})
  end
  it 'handles string with special characters' do
    is_expected.to run.with_params({ 'key' => "aString\n" }).and_return(%Q{key = "aString\\n"\n})
  end

  it 'handles nested :undef' do
    hash = {
      'key' => 'val',
      'undef' => :undef,
      'nested_undef' => {
        'undef' => :undef
      },
    }
    hcl = <<EOS
key = "val"
nested_undef {
    undef = null
}
undef = null
EOS
    is_expected.to run.with_params(hash).and_return(hcl)
  end

  it 'handles different indent' do
    hash = {
      'nested_key' => {
        'nested_key' => {
          'key' => 'val',
        },
      },
      'key' => 'val',
    }
    hcl = <<EOS
key = "val"
nested_key {
  nested_key {
    key = "val"
  }
}
EOS
    is_expected.to run.with_params(hash, 2).and_return(hcl)
  end

  it 'handles unsorted hash' do
    hash = {
      'nested_key' => {
        'nested_key2' => {
          'key2' => 'val1',
          'key1' => 'val2',
        },
        'nested_key1' => {
          'key1' => 'val1',
          'key2' => 'val2',
        },
      },
      'key' => 'val',
    }
    hcl = <<EOS
key = "val"
nested_key {
    nested_key1 {
        key1 = "val1"
        key2 = "val2"
    }
    nested_key2 {
        key1 = "val2"
        key2 = "val1"
    }
}
EOS
    is_expected.to run.with_params(hash).and_return(hcl)
  end

end
