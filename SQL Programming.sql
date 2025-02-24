/*
SQL Programming

Skills used: Joins, CTE's, aggregate functions, CAST or converting of data types, window functions

*/


-- 1. The names and the number of messages sent by each user 

SELECT 
  a.Name,
  count(b.MessageID) Messages 
FROM User a 
JOIN Messages b on a.UserID = b.UserIDSender
GROUP BY 1
ORDER BY 2 DESC; 


-- 2. The total number of messages sent stratified by weekday

SELECT 
  DAYNAME(DATE(DateSent)) as Weekday,
  COUNT(MessageID) as TotalMessages, 
  ROUND(COUNT(MessageID) * 100.0 / (SELECT COUNT(MessageID) FROM Messages), 2) AS PercentageOfTotal
FROM Messages 
GROUP BY 1 
ORDER BY FIELD(Weekday,'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'); 

/*
In this solution, I also recommend adding a column showing the percentage of the total.
This would help stakeholders quickly identify the most popular day and easily compare values, such as Sunday at 10% versus Tuesday at 20%.
Here is an example output:
| Weekday   | TotalMessages | PercentageOfTotal|
|-----------|---------------|------------------|
| Sunday    | 150           | 10.25%           |
| Monday    | 250           | 17.10%           |
| Tuesday   | 300           | 20.50%           |
| Wednesday | 220           | 15.07%           |
| Thursday  | 180           | 12.32%           |
| Friday    | 280           | 19.18%           |
| Saturday  | 120           | 8.58%            | 

Why Should You Cast DateSent to DATE?
Without Casting: The DAYNAME() function works directly on DATETIME, but it still processes the time component internally.
With Casting: Using CAST(DateSent AS DATE) or DATE(DateSent) makes the query more efficient and clear, especially for large datasets.
*/


-- 3. The most recent message from each thread that has no response yet

/*
Reasoning Behind the Code:
I assume that a message thread always begins with a sender. Based on this, I have introduced the thread status "No response – Single message" to account for cases where no reply has been received.

I assume there are two types of unanswered threads:

Waiting for a response from the recipient (when the sender sent the last message), and
Waiting for a response from the sender (when the recipient sent the last message).
In a real-world scenario, I would conduct further exploration and potentially analyse the content of the final message to determine whether a response is actually expected. For example, phrases like "Thank you", "Got it", or "No worries" could indicate that the conversation is resolved and does not require a response. This could be enhanced using natural language processing (NLP) techniques to automate the identification of such phrases.

I could also expand the analysis by calculating response rates over time to identify behavioural trends. For example:

(Latest thread by sender / Total messages sent by sender) and
(Latest thread by recipient / Total messages sent by recipient)
These metrics could be tracked as a time series to observe patterns and identify changes over time. This approach could help detect seasonal trends, sudden shifts in communication behaviour, and long-term improvements or declines in response rates.
*/ 

WITH ThreadLastMessage AS (
    SELECT 
        ThreadID,
        MessageID,
        MessageContent,
        UserIDSender AS LastSender,
        UserIDRecipient AS LastRecipient,
        DateSent,
        ROW_NUMBER() OVER (PARTITION BY ThreadID ORDER BY DateSent DESC) AS rn_desc
    FROM Messages
)
SELECT 
    tl.ThreadID,
    tl.MessageID,
    tl.MessageContent,
    tl.DateSent,
    CASE 
        WHEN m_sender.MessageID IS NULL AND m_recipient.MessageID IS NULL THEN 'No response yet (Single message)'
        WHEN m_sender.MessageID IS NULL THEN 'Waiting for Recipient response'
        WHEN m_recipient.MessageID IS NULL THEN 'Waiting for Sender response'
    END AS ThreadStatus
FROM ThreadLastMessage tl
LEFT JOIN Messages m_sender 
    ON tl.ThreadID = m_sender.ThreadID
    AND m_sender.UserIDSender = tl.LastRecipient
    AND m_sender.DateSent > tl.DateSent
LEFT JOIN Messages m_recipient 
    ON tl.ThreadID = m_recipient.ThreadID
    AND m_recipient.UserIDSender = tl.LastSender
    AND m_recipient.DateSent > tl.DateSent
WHERE tl.rn_desc = 1 
  AND (m_sender.MessageID IS NULL OR m_recipient.MessageID IS NULL)
ORDER BY tl.DateSent DESC;


-- 4. For the conversation with the most messages: all user data and message contents ordered chronologically so one can follow the whole conversation

WITH ThreadMessageCounts AS (
    SELECT ThreadID, COUNT(MessageID) AS MessageCount
    FROM Messages
    GROUP BY ThreadID
    ORDER BY MessageCount DESC
    LIMIT 1
),
RankedMessages AS (
    SELECT 
        a.ThreadID,
        a.MessageID,
        u_sender.Name AS Sender,
        u_recipient.Name AS Recipient,
        a.MessageContent,
        a.DateSent,
        LAG(a.DateSent) OVER (PARTITION BY a.ThreadID ORDER BY a.DateSent ASC) AS PreviousDateSent
    FROM Messages a
    JOIN User u_sender ON a.UserIDSender = u_sender.UserID
    JOIN User u_recipient ON a.UserIDRecipient = u_recipient.UserID
    WHERE a.ThreadID = (SELECT ThreadID FROM ThreadMessageCounts)
)
SELECT 
    ThreadID,
    MessageID,
    Sender,
    Recipient,
    MessageContent,
    DateSent,
    TIMESTAMPDIFF(SECOND, PreviousDateSent, DateSent) AS ResponseTimeInSeconds
FROM RankedMessages
ORDER BY DATE(DateSent) ASC;


/*
In this solution, I propose to also show response time. Some benefits to include this are 
- Conversation Flow: Reveals how quickly users respond, which can indicate engagement and urgency.
- User Engagement: Longer response times might indicate lower engagement or delayed conversations.
- Performance Tracking: Can help monitor whether users are responding within an expected timeframe. 

Potential output can look like the below: 
| ThreadID  |  MessageID    |      Sender| Recipient     | MessageContent                            | DateSent                 | ResponseTimeInSeconds    |
|-----------|---------------|------------|---------------|-------------------------------------------|--------------------------|--------------------------|
| 1         | 101           | Alice      | Bob           | Hi, how are you?                           | 2024-02-10 09:00:00     | NULL                     |
| 1         | 102           | Bob        | Alice         | I'm good, thanks! How about you?           | 2024-02-10 09:05:00     | 300                      |
| 1         | 103           | Alice      | Bob           | Doing well, thanks for asking!             | 2024-02-10 09:07:00     | 120                      |
| 1         | 104           | Bob        | Alice         | Great to hear! Are you free later?         | 2024-02-10 09:15:00     | 480                      |
| 1         | 105           | Alice      | Bob           | Yes, I should be free after lunch.         | 2024-02-10 09:20:00     | 300                      |
*/
