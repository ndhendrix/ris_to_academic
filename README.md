# ris_to_academic
_Converts an RIS bibliography into the format required for the Academic Hugo theme_

The [Academic theme](https://evamaerey.github.io/what_how_guides/academic_website_w_blogdown) for Hugo is an easy way for researchers and creators to maintain a website.

One of the theme's best features is that it creates a searchable database of your publications. For researchers with an extensive publication history, it can be daunting to convert all your publications into the format required by the theme.

I've created this script to convert RIS bibliographies into that format. 

Instructions for use:
1. Download a bibliography in RIS format. **This script has only been tested with RIS files from Web of Science.**
2. Open this script in R.
3. Set the directory for output. I suggest that you don't use the folder your website is stored in.
4. Run the script.
5. Double check that everything looks okay. If so, then copy all the folders it produced to the "~/content/publication" folder of your website. If not, consider creating a branch of this script and fixing it -- or telling me what the problem is and I can try.
