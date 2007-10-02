From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 11:47:12 +0000
Subject: Re: [PATCH 4/9]: Resolve dependencies of features on choice of CCID
Message-Id: <200710021247.12463@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200709281630.22458@strip-the-willow>
In-Reply-To: <200709281630.22458@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  I don't quite understand why you're defining on and off when there is
|  built in stuff for the kernel for true/false. You then pass the
|  address of the on/off - not the value. Maybe you might like to explain
|  the rationale behind this as I'm probably missing something.
No you are not - thanks so much for pointing this out! These constants have
been a constant eyesore and I had wanted to get rid of them, but lacked an
idea. 

The pointer was used to have a sentinel in the table, since the caller can not
know how large the table is. But a look at RFC 4340, 6.4 showed that `0' is 
never a valid feature number, so that is used as an end-of-table condition now.

Thanks a lot.
