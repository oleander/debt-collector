require 'pathname'
require 'pry'

def find_spec_file(path, base_path = Pathname.pwd)
  if path.is_a?(String)
    return find_spec_file(Pathname.new(path), base_path)
  elsif !path.is_a?(Pathname)
    raise ArgumentError, 'file_path must be a String or Pathname'
  elsif path.absolute?
    return find_spec_file(path.relative_path_from(base_path), base_path)
  end

  puts "Input path: #{path}"
  puts "Root folder: #{base_path}"

  # dir: a/bc/c, file: d.rb
  dir, file = path.split
  puts "Dir: #{dir}, file: #{file}"

  # d_spec.rb
  spec_name = file.sub_ext('_spec.rb')
  puts "Spec name: #{spec_name}"

  # [a, b, c ]
  sections = dir.to_s.split('/')

  # [[spec, **, a, b, c, d_spec.rb], [spec, **, a, b, d_spec.rb], ...]
  globs = sections.size.times.map do |n|
    wildcard = n.zero? ? [] : ['**']
    ['spec', *wildcard, *sections.drop(n), spec_name.to_s].join('/')
  end

  puts "Found #{globs.size} patterns:"
  globs.each do |pattern|
    puts "\t#{pattern}"
  end

  globs.each do |pattern|
    base_path.glob(pattern).each do |spec_file|
      return spec_file
    end
  end

  raise ArgumentError, "Could not find #{path} in #{base_path} matching patterns"
end

def all_specs(base_path = Pathname.pwd)
  Dir.glob('spec/**/*_spec.rb')
end

def all_files(base_path = Pathname.pwd)
  Dir.glob('**/*.rb')
end

def other_files(base_path = Pathname.pwd)
  all_files(base_path) - all_specs(base_path)
end

root_path = Pathname.new("/Users/linus/Code/datajust")
matched_file = other_files
puts "Found #{matched_file.size} files"

result = matched_files.reduce({}) do |acc, file|
  spec_files = find_spec_file(file.first, root_path)
  payload = { file.relative_path_from(root_path).to_s => spec_files }
  final = acc.merge(payload)
  puts "Final: #{final}"
  final
end

puts "Found #{result.size} spec files"
pp result

