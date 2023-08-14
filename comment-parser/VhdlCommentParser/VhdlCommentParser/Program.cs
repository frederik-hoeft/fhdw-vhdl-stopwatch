using System.Text;
using System.Text.RegularExpressions;

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
using StreamWriter outputWriter = new(output);

string outputFileName2 = args[0].Replace(".csv", string.Empty) + "-outputs.txt";
if (File.Exists(outputFileName2))
{
    File.Delete(outputFileName2);
}
using FileStream output2 = File.OpenWrite(outputFileName2);
using StreamWriter output2Writer = new(output2);

// ignore the first line when copying the content to a txt file
for (int i = 1; i < lines.Length; i++)
{
    string[] inputsAndOutputs = GetEmptyColumnRegex().Split(lines[i]);
    if (inputsAndOutputs.Length != 2)
    {
        Console.WriteLine("Could not detect input and output sections. Please provide input and output data separated by an empty column.");
        return;
    }
    string inputs = inputsAndOutputs[0];
    string outputs = inputsAndOutputs[1];

    List<string> inputWords = GetColumnsRegex().Split(inputs).ToList();
    // remove the first column of each line
    string processedInputWords = string.Join(' ', inputWords.Skip(1));
    outputWriter.Write(processedInputWords);
    if (i < lines.Length - 1)
    {
        outputWriter.WriteLine();
    }

    List<string> outputWords = GetColumnsRegex().Split(outputs).ToList();
    string processedOutputWords = string.Join(' ', outputWords);
    output2Writer.Write(processedOutputWords);
    if (i < lines.Length - 1)
    {
        output2Writer.WriteLine();
    }
}

partial class Program
{
    [GeneratedRegex("(;|,)")]
    private static partial Regex GetColumnsRegex();
}

partial class Program
{
    [GeneratedRegex("(;;|,,)")]
    private static partial Regex GetEmptyColumnRegex();
}