
// sdk
import structs/[HashMap, ArrayList]
import io/File
import os/ShellUtils
import text/StringTokenizer

// ours
import sam/[Base]

Arguments: class {

    home: File
    longs := HashMap<String, String> new()
    shorts := HashMap<String, String> new()
    args := ArrayList<String> new()

    size ::= args size

    operator [] (index: Int) -> String {
        args[index]
    }

    hasLong?: func (s: String) -> Bool {
        longs contains?(s)
    }

    init: func (commandLine: ArrayList<String>) {
        parser := ArgumentsParser new(commandLine)

        execFile := File new(parser pop())

        execFile2 := ShellUtils findExecutable(execFile name, false)
        if (execFile2) {
            home = execFile2 getAbsoluteFile() parent
        } else {
            home = execFile getAbsoluteFile() parent
        }

        while (parser hasNext?) {
            arg := parser pop()
            match {
                case arg startsWith?("--") =>
                    if (arg contains?("=")) {
                        tokens := arg[2..-1] split("=")
                        longs put(tokens[0], tokens[1])
                    } else {
                        longs put(arg[2..-1], "")
                    }
                case arg startsWith?("-") =>
                    shorts put(arg[1..-1], "")
                case =>
                    args add(arg)
            }
        }

        "Arguments: " println()
        for (arg in args) {
            "arg #{arg}" println()
        }
        longs each(|key, value|
            "long '#{key}' => '#{value}'" println()
        )
        shorts each(|key, value|
            "short '#{key}' => '#{value}'" println()
        )
    }

}

ArgumentsParser: class {

    buffer := ArrayList<String> new()
    hasNext? ::= !buffer empty?()

    init: func (commandLine: ArrayList<String>) {
        buffer = commandLine clone()
    }

    pop: func -> String {
        buffer removeAt(0)
    }

}

