require 'ruble'

@@COUNT = 1

command 'Getter/Setter generator' do |cmd|
  cmd.scope = 'source.php'
  cmd.output = :insert_as_snippet
  cmd.input = :document
  cmd.key_binding = "Alt+Shift+S"
  cmd.invoke do |context|
    vars     = get_vars
    contents = context.input
    props     = []
    vars.each { |var|
      if var.match(/(?:public|protected|private|var)\s*\$(\w+);/)
        props.push(get_both($1, contents))
      end
    }

    print_content(contents, props)
  end
end

def print_content(contents, props)
  last = contents.rindex("}")
  ter  = contents.rindex("?")
  contents[last]  = ''
  contents[ter]   = ''
  contents[ter-1] = ''
  contents.gsub!('$', '\$')
  contents += "\n\t" + props.join("\n\n\t") + "\n}\n\n?>"

  print contents
end

def get_vars
  vars = ENV['TM_SELECTED_TEXT'].nil? ? ENV['TM_CURRENT_LINE'] : ENV['TM_SELECTED_TEXT']
  vars.split("\n")
end

def get_getter(name, contents, nominalName)
  getter = 'get' + nominalName
  if contents.match(/#{getter}/)
  return
  end

  '/**
     * Get ' + name + '
     *
     * @return ${' + @@COUNT.to_s + ':VariableType}
     */
    public function ' + getter + '(){
        return \$this->' + name + ';
    }'
end

def get_setter(name, contents, nominalName)
  setter = 'set' + nominalName

  if contents.match(/#{setter}/)
  return
  end

  '/**
     * Set ' + name + '
     *
     * @param ${' + @@COUNT.to_s + ':VariableType} \$' + name + '
     */
    public function ' + setter + '(\$' + name + '){
        \$this->' + name + ' = \$' + name + ';
    }'
end

def get_both(name, contents)
  varName = name.slice(0,1).capitalize + name.slice(1..-1)
  out = "\t" + get_getter(name, contents, varName).to_s
  out += "\n\n"
  out += "\t" + get_setter(name, contents, varName).to_s

  @@COUNT += 1

  return out.strip
end
