#include <iostream>
#include <fstream>
#include <string>

using namespace std;

std::size_t find(std::vector<string> names, std::string name)
{
    for (std::size_t i = 0; i < names.size(); i++)
        if (names[i] == name)
            return i;
    cout << "Error unable to find name " << name << "\n";
    exit(-1);
}

std::vector<std::size_t> find_ending(std::vector<string> names, std::string ending)
{
    std::vector<std::size_t> sub_names;
    for (std::size_t i = 0; i < names.size(); i++)
        if (names[i].substr(2, 1) == ending)
            sub_names.push_back(i);
    return sub_names;
}

int main()
{
    string line;
    std::vector<std::size_t> choices;
    std::vector<std::string> names;
    std::vector<std::size_t> paths;
    std::string filename = "eighth.txt";

    ifstream file(filename);
    if (file.is_open())
    {
        getline(file, line);
        for (std::string::size_type i = 0; i < line.size(); i++)
            choices.push_back(line[i] == 'R' ? 1 : 0);
        getline(file, line);
        while (getline(file, line))
            names.push_back(line.substr(0, 3));
        file.close();
    }

    ifstream file_again(filename);
    if (file_again.is_open())
    {
        getline(file_again, line);
        getline(file_again, line);
        while (getline(file_again, line))
        {
            paths.push_back(find(names, line.substr(7, 3)));
            paths.push_back(find(names, line.substr(12, 3)));
        }
        file_again.close();
    }

    // Part 1
    std::size_t o = find(names, "AAA");
    long steps_1 = 0;
    while (o != find(names, "ZZZ"))
    {
        for (std::size_t i = 0; i < choices.size(); i++)
        {
            o = paths[2 * o + choices[i]];
            steps_1++;
        }
    }
    cout << "Part 1: " << steps_1 << "\n";

    // Part 2
    std::vector<std::size_t> os = find_ending(names, "A");
    std::vector<std::size_t> zs = find_ending(names, "Z");

    std::vector<std::size_t> paths_combined;
    for (std::size_t i = 0; i < names.size(); i++)
    {
        std::size_t o2 = i;
        for (std::size_t j = 0; j < choices.size(); j++)
            o2 = paths[2 * o2 + choices[j]];
        paths_combined.push_back(o2);
    }

    // First step moves all os into a repeating orbit
    for (std::size_t i = 0; i < os.size(); i++)
        os[i] = paths_combined[os[i]];

    // The sizes of each orbit is a prime, and the distance
    // to the end-goal is maximal
    std::vector<long> orbit_sizes;
    for (std::size_t i = 0; i < os.size(); i++)
    {
        std::size_t starting_point = os[i];
        std::size_t j = 0;
        while (std::find(zs.begin(), zs.end(), os[i]) == zs.end())
        {
            os[i] = paths_combined[os[i]];
            j++;
        }
        if (paths_combined[os[i]] != starting_point)
        {
            cout << "Orbit assumption incorrect\n";
            exit(-1);
        }
        orbit_sizes.push_back(j + 1);
    }

    // We need to find -1 mod orbit size for each.
    // We get that by subtracting 1 from the product of all orbit sizes.
    // Then we add the first step we took into the orbit.
    // All in all, the end result is the product of
    // all orbit sizes, multiplied by the number of steps
    // in a single combined step.
    long part_2 = 1;
    for (std::size_t i = 0; i < orbit_sizes.size(); i++)
        part_2 *= orbit_sizes[i];
    cout << "Part 2: " << part_2 * choices.size() << "\n";

    return 0;
}
