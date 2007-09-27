From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 27 Sep 2007 08:19:53 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <200709270919.53474@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Quoting Tommi Saviranta:
|  >   1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
|  > the ccid-4.c, as suggested by Ian and Arnaldo
|  >   2 - for more complex functions, write a dccp_ccid3_lib.ko, as
|  > suggested by arnaldo
|  
|  There is very little more to say about this, really. The code should and
|  needs to be shared. I just have this bad feeling that ccid3.c will
|  become nothing but a skeleton file that does all the work in
|  dccp_ccid3_lib.
|  
I have thought about this - and had an idea to eliminate one extra library:

 * use a .ko file for the functions called by both CCID3 and CCID4 as suggested by Arnaldo
 * but there is already dccp_tfrc_lib which hosts a major number of functions used by CCID3/4
 * hence I think that you could proceed by
	- add a CCID-3 specific object file to dccp_tfrc_lib-y in net/dccp/ccids/lib/Makefile
          (eg. ccid3_funcs.o or whatever)
	- the file could take the shared functions, ccid3.c could then be stripped to smaller functions
	  which wrap around the library functions
	- tfrc.h could take the declarations
 * this way one library less to look after.

Ian/Arnaldo may also have ideas or opinions on this.
