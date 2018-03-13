import assembler_main.Assembler;
import assembler_main.binary_instructions.toolset.Tools;

import java.io.File;
import java.io.FileNotFoundException;

/**
 * Created by Andrei-ch on 2016-03-19.
 */
public class Driver {

    /**
     * run assembler.
     * Assumes Driver.java is placed in path ...CPUS/cpu/bin
     * Assumes code to assemble is placed at ...CPUS/cpu/tests
     *
     * @param args
     */
    public static void main(String[] args) {
        String read_from;
        String write_to;
        boolean testing = true;
        if (testing) {
            read_from = "./resources/jtest.asm";
            write_to = "./resources/Init.dat";
        } else {
            if (args.length < 1) {
                Tools.print("Missing .asm file input. Please add this to command line.");
                System.exit(-1);
            }
            read_from = getPath("Driver.java");
            read_from = read_from.substring(0, read_from.length() - ("Driver.java").length() - 4);
            read_from += File.separatorChar + "tests" + File.separatorChar + args[0];
            write_to = read_from.substring(0, read_from.length() - 4) + ".dat";
        }
        Assembler.assemble(read_from, write_to);
    }

    public static String getPath(String name) {
        File f = new File(name);
        return f.getAbsolutePath();
    }
}
