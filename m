From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 20 Jul 2007 12:55:41 +0000
Subject: Re: iperf
Message-Id: <200707201355.41549@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
In-Reply-To: <5bc4c4570707171213v6eb89545y5970e471345cc3f8@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Thanks everyone for sending test reports.

|  Question - what do you get on an unpatched 2.6.20 kernel? I think this
|  is my patches making it work well but want to verify that it's not
|  just something breaking between 2.6.20 and 2.6.22.
Fully agree here: I am not sure that these problems are necessarily due to a DCCP 
problem and actually would like to put the following question to the list - 
   - to what extent should the DCCP test tree track 
     the latest developments on the netdev tree?

My understanding that it is a good thing to track netdev, but it will make debugging
a bit more laborious. It is an acknowledged issue that there are still many bugs 
outstanding in 2.6.21/22, and I have been experiencing many crashes during the last
month which vanished mysteriously a couple of days/revisions later.

You can help us and hopefully other developers by supplying as much information as
you can get:
 * use constant bitrate and full byte-blast of iperf
 * use dccp_probe (as suggested by Ian, CBR produces much less noise in the output)
 * use different hardware (Wifi, 10mpbs, 100mbps, bluetooth, other arches)

I will also try and replicate this. Please provide as detailed information as you can.
