From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Jan 2007 13:22:23 +0000
Subject: Re: [PATCH 1/5]: DCCP Fix use of invalid loss intervals
Message-Id: <200701051322.24178@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201544.22122.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201544.22122.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Eddie,

thanks a lot for looking into this and I think we should take this on board and find 
a different solution to achieve the same purpose, but without comparison against ~0 or ~0U.

|  But the two bit patterns are the same, and the comparison will promote 
|  them both to unsigned.
Using both signed and unsigned can lead to very subtle bugs. As a recent example, we have had
real problems because time differences (signed type) was implicitly converted to unsigned.

The use of ~0U appears in the following functions:
	* to mark a loss interval as empty in dccp_li_hist_interval_new
	* to find non-empty loss intervals in dccp_li_hist_calc_i_mean
	* to mark an empty first loss interval in ccid3_hc_rx_calc_first_li
          (also connected with catching error conditions)

Sometimes the conversion happens through the return type, sometimes directly: it is not obvious
to see what happens here.

So I agree with Eddie and think we should find a different way of identifying empty loss intervals;
or check each part of the code to make sure it will be safe. 

I can also see the point Ian makes, in that this will require some work - hence added as ToDo item on 
http://linux-net.osdl.org/index.php/TODO#DCCP

Gerrit


|  Try running the following program:
|  
|  int main (int c, char **v)
|  {
|       if (~0 != ~0U)
|  	printf("not equal as unknown");
|       if ((int) ~0 != (int) ~0U)
|  	printf("not equal as ints");
|       if ((unsigned) ~0 != (unsigned) ~0U)
|  	printf("not equal as unsigneds");
|       if ((int) ~0 != (unsigned) ~0U)
|  	printf("not equal as int/unsigned");
|       if ((unsigned) ~0 != (int) ~0U)
|  	printf("not equal as unsigned/int");
|  }
|  
|  It prints nothing.
|  
|  If one of the two numbers is 64-bit, your analysis works.  Maybe I'm 
|  missing something but I don't think so...
|  Eddie
|  
|  
|  
|  Ian McDonald wrote:
|  > On 1/5/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
|  >> Ian (catching up slowly slowly), here is a nit as nitty as they come.
|  >>
|  >> This diff seems strange to me, since ~ actually does the same thing on
|  >> integers and unsigned integers.  (This code:
|  >>
|  >>      printf("%u %u\n", ~0, ~0U);
|  >>
|  >> will print the same thing twice.)
|  >>
|  >> Perhaps dccplih_interval is a 64-bit number?  In which case you want to
|  >> say something like ~0ULL?
|  >>
|  >> Eddie
|  > 
|  > Printing gives them the same result as you are using a %u mask. If you
|  > do it with a %d mask you will get a different result.
|  > 
|  > And that is the issue dccp_lih_interval is unsigned 32 bit and ~0 is a
|  > signed number and is large negative and they therefore can't be equal.
|  > 
|  > Ian
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
