/*
*  lists taken from http://www.becomeawordgameexpert.com/wordlists.htm
*  args[0] as file name of form:  .*Raw.*\.txt
* 	outputs to file name with Raw replaced by # of words contained within
*/

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Scanner;

public class CountWordListRaw {
	public static void main(String[] args)
	{
		if (args.length != 1)
		{
			System.out.println("Argument needed, file name of form: .*Raw.*\\.txt");
			return;
		}
		if (!args[0].matches(".*Raw.*\\.txt"))
		{
			System.out.println("Argument needed, file name of form: .*Raw.*\\.txt");
			return;
		}
		
		int total = 0;
		String line = "";
		try
		{
			File in = new File(args[0]);
			Scanner s = new Scanner(in);
			System.out.println("Scanning...");
			line = s.nextLine().toLowerCase();
			total = line.split(" ").length;
		}
		catch (FileNotFoundException e)
		{
			System.out.println("File not found: "+args[0]);
		}
				
		Path out = Paths.get(args[0].replace("Raw", String.valueOf(total)));
		try
		{
			System.out.println("Writing to "+out+"...");
			BufferedWriter convert = Files.newBufferedWriter(out, StandardCharsets.US_ASCII);
			convert.write(line);
			convert.flush();
		}
		catch (IOException e)
		{
			System.out.println("Couldn't write to: "+out);
		}
	}
}
