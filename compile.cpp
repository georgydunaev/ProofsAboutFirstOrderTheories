#include <iostream>
using std::cout;
using std::cin;
#include <fstream>
using std::ifstream;
#include <string>
using std::string;
#include <vector>
using std::vector;
#include <iterator>
using std::istream_iterator;
#include <algorithm>
using std::copy;
using namespace std;

const string pathCOQC = "/home/user/opam-coq.8.8.1/4.02.3/bin/coqc";
const string pathlib = "/home/user/0my/GITHUB/VerifiedMathFoundations/library";
/*
#include <iostream>
#include <experimental/filesystem>
namespace fs = std::experimental::filesystem;
int notmain()
{
    std::cout << "Temp directory is " << fs::temp_directory_path() << '\n';
}
*/

int main(int argc, char * argv[]){
    int i;
    for(i = 0; i < argc; i++){
        std::cout << "Argument "<< i << " = " << argv[i] << std::endl;
    }
    //notmain(); exit(0);
    // Store the words from the two files into these two vectors
    vector<string> DataArray;
    //vector<string> QueryArray;

    // Create two input streams, opening the named files in the process.
    // You only need to check for failure if you want to distinguish
    // between "no file" and "empty file". In this example, the two
    // situations are equivalent.
    string name;
    if(argc==2) {name = argv[1];} 
    else {name = "compilation2Pred.txt";}
    ifstream myfile(name.c_str()); 
    //ifstream qfile("queries.txt");

    // std::copy(InputIt first, InputIt last, OutputIt out) copies all
    //   of the data in the range [first, last) to the output iterator "out"
    // istream_iterator() is an input iterator that reads items from the
    //   named file stream
    // back_inserter() returns an interator that performs "push_back"
    //   on the named vector.
    copy(istream_iterator<string>(myfile),
         istream_iterator<string>(),
         back_inserter(DataArray));
    /*copy(istream_iterator<string>(qfile),
         istream_iterator<string>(),
         back_inserter(QueryArray));*/
    int len=DataArray.size();
    string command1 = "cp ";
    string command2 = pathCOQC+" ./library/";
    for(int i=0;i<len;++i) {
    string nm=DataArray[i];
    auto c1 = string("ADD_PATH&COPY "/*"cp "*/)+nm+string(" ./library/")+nm;
    cout<<c1<<endl;

    // HERE COPY AND ADD STRING.
    //system(c1.c_str());

{
    std::string line;
    vector<string> code; // all file 
    ifstream qfile(nm);

    if(!qfile) //Always test the file open.
    {
        cout<<"Error opening input file"<<endl;
        //system("pause"); return -1;
    }
    code.push_back(string("Add LoadPath \"")+pathlib+string("\"."));
    while (std::getline(qfile, line))
    {
        code.push_back(line);
    }
    cout<<"Print here: "<<string("./library/")+nm<<endl;
    ofstream outfile(string("./library/")+nm);
    int le = code.size();
    for(unsigned int i=0; i<le; i++)
      outfile << code[i] << endl;
}

    auto c2 = command2+nm;
    cout<<c2<<endl;
    system(c2.c_str());

    }
    try {

        // use ".at()" and catch the resulting exception if there is any
        // chance that the index is bogus. Since we are reading external files,
        // there is every chance that the index is bogus.
        // cout<<QueryArray.at(20)<<"\n";
        //cout<<DataArray.at(12)<<"\n";
    } catch(...) {
        // deal with error here. Maybe:
        //   the input file doesn't exist
        //   the ifstream creation failed for some other reason
        //   the string reads didn't work
        cout << "Data Unavailable\n";
    }
    return 0;
}
