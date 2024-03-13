import csv

if __name__ == "__main__":
    user_file = "users.csv"
    user_out_file = "users_clean.csv"

    """
    users.csv alittle messy:
        - IDs are float when it should be int
        - there are 2 "created_at" columns, will remove the second one
    """
    with open(user_file) as f, open(user_out_file, 'w') as o:
        user_csv = csv.reader(f, delimiter=',')
        user_out_csv = csv.writer(o, delimiter=',')
        header = next(user_csv)
        header.pop(5)
        user_out_csv.writerow(header)
        c = 0
        for row in user_csv:
            row[0] = int(float(row[0]))
            row[3] = int(float(row[3]))
            row.pop(5)
            user_out_csv.writerow(row)
            c += 1
            if c % 10000 == 0:
                print(f"{c} rows cleaned")
        print(f"{c} total rows cleaned")
    
    subs_file = "subscriptions.csv"
    subs_out_file = "subscriptions_clean.csv"

    """
    subscriptions.csv alittle messy:
        - timestamps are flipped sometimes, 
    """
    with open(subs_file) as f, open(subs_out_file, 'w') as o:
        subs_csv = csv.reader(f, delimiter=',')
        subs_out_csv = csv.writer(o, delimiter=',')
        header = next(subs_csv)
        subs_out_csv.writerow(header)
        c = 0
        for row in subs_csv:
            # switch rows 2 and 3 if term_start is greater than term_end
            if row[2] > row[3]:
                row[2], row[3] = row[3], row[2]
            subs_out_csv.writerow(row)
            c += 1
            if c % 10000 == 0:
                print(f"{c} rows cleaned")
        print(f"{c} total rows cleaned")
