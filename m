From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 27 Nov 2006 19:29:57 +0000
Subject: Re: [PATCH 0/3]: TFRC documentation and updates
Message-Id: <5640c7e00611271129sd341605m9346b1c85384b3c4@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/28/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> With the help of some test and verification programs, I have reverse-engineered
> how the TFRC lookup table is generated. The results of this were added as detailed
> documentation to the tfrc_equation.c file.

Well done. This code was in need of some tidyup and improving. I
remember with pain working in this area.

If it is of any use the program you reverse engineered is now up on
the web here:
http://wand.net.nz/~iam4/dccp/ccid3_calc.c

I'll look at those patches when I can.

Regards,

Ian
-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
