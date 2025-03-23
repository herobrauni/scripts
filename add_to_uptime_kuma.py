import sqlite3
import sys
import yaml

def check_monitor_exists(cursor, name):
    cursor.execute("SELECT id FROM monitor WHERE name = ?", (name,))
    result = cursor.fetchone()
    return result[0] if result else None

def insert_monitor(cursor, name, monitor_type, parent_id=None, hostname=None):
    # Base default values
    values = {
        'name': name,
        'active': 1,
        'user_id': 1,
        'interval': 60,
        'url': 'https://',
        'type': monitor_type,
        'weight': 2000,
        'created_date': '2025-03-23 10:55:38',
        'maxretries': 0,
        'ignore_tls': 0,
        'upside_down': 0,
        'maxredirects': 10,
        'accepted_statuscodes_json': '["200-299"]',
        'dns_resolve_type': 'A',
        'dns_resolve_server': '1.1.1.1',
        'retry_interval': 60,
        'method': 'GET',
        'docker_host': 0,
        'packet_size': 56,
        'kafka_producer_sasl_options': '{"mechanism":"None"}',
        'oauth_auth_method': 'client_secret_basic',
        'timeout': 48.0,
        'gamedig_given_port_only': 1,
        'kafka_producer_ssl': 0,
        'kafka_producer_allow_auto_topic_creation': 0
    }

    # Modify values for ping and tailscale-ping types
    if monitor_type in ['ping', 'tailscale-ping']:
        values['hostname'] = hostname
        values['parent'] = parent_id

    fields = list(values.keys())
    sql = f'''INSERT INTO monitor (
        {', '.join(fields)}
    ) VALUES (
        {', '.join(['?' for _ in fields])}
    )'''
    
    cursor.execute(sql, tuple(values[field] for field in fields))
    return cursor.lastrowid

def process_host(cursor, hostname, ip):
    results = {
        'successful_groups': [],
        'successful_pings': [],
        'successful_tailscale': [],
        'skipped_groups': [],
        'skipped_pings': [],
        'skipped_tailscale': [],
        'failed': []
    }

    try:
        # Check and create group
        group_id = check_monitor_exists(cursor, hostname)
        if group_id is None:
            group_id = insert_monitor(cursor, hostname, 'group')
            results['successful_groups'].append(hostname)
        else:
            results['skipped_groups'].append(hostname)

        # Create ping monitor
        ping_name = f"{hostname}_ping"
        if check_monitor_exists(cursor, ping_name) is None:
            insert_monitor(cursor, ping_name, 'ping', group_id, ip)
            results['successful_pings'].append((ping_name, ip))
        else:
            results['skipped_pings'].append((ping_name, ip))

        # Create tailscale-ping monitor
        tailscale_name = f"{hostname}_tailscale"
        tailscale_hostname = f"{hostname}.brill-bebop.ts.net"
        if check_monitor_exists(cursor, tailscale_name) is None:
            insert_monitor(cursor, tailscale_name, 'tailscale-ping', group_id, tailscale_hostname)
            results['successful_tailscale'].append((tailscale_name, tailscale_hostname))
        else:
            results['skipped_tailscale'].append((tailscale_name, tailscale_hostname))

    except sqlite3.Error as e:
        results['failed'].append((hostname, str(e)))

    return results

def print_results(results):
    print("\nResults:")
    print(f"Groups added: {len(results['successful_groups'])}")
    print(f"Groups skipped: {len(results['skipped_groups'])}")
    print(f"Ping monitors added: {len(results['successful_pings'])}")
    print(f"Ping monitors skipped: {len(results['skipped_pings'])}")
    print(f"Tailscale monitors added: {len(results['successful_tailscale'])}")
    print(f"Tailscale monitors skipped: {len(results['skipped_tailscale'])}")
    print(f"Failed: {len(results['failed'])}")

    if results['successful_groups']:
        print("\nSuccessful group entries:")
        for hostname in results['successful_groups']:
            print(f"  - {hostname}")

    if results['successful_pings']:
        print("\nSuccessful ping entries:")
        for name, ip in results['successful_pings']:
            print(f"  - {name} ({ip})")

    if results['successful_tailscale']:
        print("\nSuccessful tailscale entries:")
        for name, hostname in results['successful_tailscale']:
            print(f"  - {name} ({hostname})")

    if results['skipped_groups']:
        print("\nSkipped group entries (already exist):")
        for hostname in results['skipped_groups']:
            print(f"  - {hostname}")

    if results['skipped_pings']:
        print("\nSkipped ping entries (already exist):")
        for name, ip in results['skipped_pings']:
            print(f"  - {name} ({ip})")

    if results['skipped_tailscale']:
        print("\nSkipped tailscale entries (already exist):")
        for name, hostname in results['skipped_tailscale']:
            print(f"  - {name} ({hostname})")

    if results['failed']:
        print("\nFailed entries:")
        for hostname, error in results['failed']:
            print(f"  - {hostname}: {error}")

def main():
    if len(sys.argv) not in [2, 3]:
        print("Usage:")
        print("  python script.py hosts.yml")
        print("  python script.py hostname ip")
        sys.exit(1)

    try:
        # Connect to database
        conn = sqlite3.connect('/opt/uptime-kuma/data/kuma.db')
        cursor = conn.cursor()

        if len(sys.argv) == 2:  # YAML file mode
            yml_file = sys.argv[1]
            # Read hostnames from YAML file
            with open(yml_file, 'r') as f:
                hosts_data = yaml.safe_load(f)

            if not hosts_data:
                print("No entries found in the YAML file!")
                sys.exit(1)

            # Initialize combined results
            combined_results = {
                'successful_groups': [], 'successful_pings': [], 'successful_tailscale': [],
                'skipped_groups': [], 'skipped_pings': [], 'skipped_tailscale': [],
                'failed': []
            }

            # Process each host
            for hostname, ip in hosts_data.items():
                results = process_host(cursor, hostname, ip)
                # Combine results
                for key in combined_results:
                    combined_results[key].extend(results[key])

            print_results(combined_results)

        else:  # Single host mode
            hostname = sys.argv[1]
            ip = sys.argv[2]
            results = process_host(cursor, hostname, ip)
            print_results(results)

        # Commit all changes
        conn.commit()

    except FileNotFoundError:
        print(f"Error: File '{yml_file}' not found!")
    except yaml.YAMLError as e:
        print(f"YAML parsing error: {e}")
    except sqlite3.Error as e:
        print(f"Database error: {e}")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    main()