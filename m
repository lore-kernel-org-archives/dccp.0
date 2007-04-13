From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 08:23:14 +0000
Subject: Re: [PATCH 24/25]: Macro for moving average
Message-Id: <200704130923.14459@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211846.10823@strip-the-willow>
In-Reply-To: <200703211846.10823@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I don't like macros that receive as a parameter something that will be
|  changed, its more readable to have it as a inline function and return
|  the new value, even if the resulting code uses more characters, so I'm
|  applying the attached patch and will take care of the fallout, that is
|  small from what I grepped at the_whole_lot.
You are right (please see other comment), I wasn't overly happy with this one.
Your change makes it much better and avoids future problems due to someone
misinterpreting the macro arguments. Many thanks indeed.
