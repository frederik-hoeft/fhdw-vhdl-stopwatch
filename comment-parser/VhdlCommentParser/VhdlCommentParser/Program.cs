using System.Text;

// Requires:
// -> Csv file as input with the first line and first column being used for comments
// + an input data section beginning at line 2 column 2
// + an output data section that is separated from the input section by an empty column
// Functionality:
// -> Converts the csv file into two txt files
// + the first txt file contains the data from the input section of the original csv file
// + the second txt file contains the data from the output section of the original csv 

if (args.Length is 0 or > 1)
{
    Console.WriteLine("Usage: dotnet run --project <path-to-project>/VhdlCommentParser.csproj <file>");
    return;
}

string[] lines = File.ReadAllLines(args[0]);

string outputFileName = args[0].Replace(".csv", string.Empty) + "-inputs.txt";
if (File.Exists(outputFileName))
{
    File.Delete(outputFileName);
}
using FileStream output = File.OpenWrite(outputFileName);

string outputFileName2 = args[0].Replace(".csv", string.Empty) + "-outputs.txt";
if (File.Exists(outputFileName2))
{
    File.Delete(outputFileName2);
}
using FileStream output2 = File.OpenWrite(outputFileName2);

// ignore the first line when copying the content to a txt file
for (int i = 1; i < lines.Length; i++)
{
    string[] inputsAndOutputs = lines[i].Split(";;");
    if (inputsAndOutputs.Length != 2)
    {
        Console.WriteLine("Could not detect input and output sections. Please provide input and output data separated by an empty column.");
        return;
    }
    string inputs = inputsAndOutputs[0];
    string outputs = inputsAndOutputs[1];

    List<string> inputWords = inputs.Split(";").ToList();
    // remove the first column of each line
    string processedInputWords = string.Join(string.Empty, inputWords.Skip(1));
    output.Write(Encoding.UTF8.GetBytes(processedInputWords + "\r\n"));

    List<string> outputWords = outputs.Split(";").ToList();
    string processedOutputWords = string.Join(string.Empty, outputWords);
    output2.Write(Encoding.UTF8.GetBytes(processedOutputWords + "\r\n"));
}