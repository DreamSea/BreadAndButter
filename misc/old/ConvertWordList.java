/*
*  lists taken from http://www.becomeawordgameexpert.com/wordlists.htm
*  args[0] as file name of form:  .*Raw.*\.txt
*  outputs into a file name where Raw is replaced by number of entries
*	Converts space seperated words on a single line located in input file
*  Writes to output file same word list, one line per word
*/

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Scanner;


public class ConvertWordList {
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
		
		ArrayList<String> words = new ArrayList<>();
		int total = 0;
		try
		{
			File in = new File(args[0]);
			Scanner s = new Scanner(in);
			System.out.println("Scanning...");
			while (s.hasNext())
			{
				total++;
				words.add(s.next().trim().toLowerCase());
			}
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
			for (String s : words)
			{
				convert.write(s);
				convert.write("\r\n");
			}
			convert.flush();
		}
		catch (IOException e)
		{
			System.out.println("Couldn't write to: "+out);
		}
	}
}
