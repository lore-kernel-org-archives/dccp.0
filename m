From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 22 Sep 2006 17:51:31 +0000
Subject: Re: [PATCH 7/7] [DCCP]: Remove socket option
Message-Id: <200609221851.31561@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200609221433.48612.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200609221433.48612.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  Hi, a bit of re-clarification:  CCIDs 2 and 3 are *not* meant for apps that 
|  NEVER vary their packet size.  Rather, they are meant for apps that very 
|  packet size *for application reasons* (such as codec output), but *not* in 
|  response to congestion.  CCIDs 2 and 3 expect to reduce application RATES in 
|  response to congestion.
My understanding is that there is very little wisdom currently regarding applications
which vary their packet sizes due to application reasons; I have copied the quotes
I am referring to below. The work-in-progress draft-ietf-dccp-tfrc-voip-05.txt
is not very outspoken about what happens if the application changes its packet size.

[RFC 4341, sec. 5.3]: "CCID 2 is optimized for applications that generally use a fixed
                       packet size and vary their sending rate in packets per second in
                       response to congestion."
[RFC 4342, sec. 5.3]: "CCID 3 is intended for applications that use a fixed packet size, and
                       that vary their sending rate in packets per second in response to
                       congestion."

If we allow applications to violate these premises then I don't know how to fix this in the code.
  

|  In summary, in the longer-term deriving 's' from observations would work, but 
|  I don't see any objection to this socket option in the short term or the long 
|  term.  It allows the application to explicitly state its intent, which is 
|  usually useful.
I would like to suggest a compromise: retaining an experimental patch which allows
this socket option and can be used for people interested in experimenting with these
ideas, to gain new insights; and to leave the main kernel API as simple as it can
possibly be made. 


--Gerrit
