'''
 Copyright (C) 2024  Synconics Technologies Pvt. Ltd.

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 odooprojecttimesheet is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''

import xmlrpc.client
import logging
from datetime import datetime
import requests
import urllib3
urllib3.disable_warnings()
import json
http = urllib3.PoolManager(cert_reqs='CERT_NONE')

logging.basicConfig(level=logging.DEBUG)
logging.basicConfig(filename='app.log', level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')


url = False
db = False
uid = False
password = False

def logout():
    global url
    url = False
    global db
    db = False
    global uid
    uid = False
    global password
    password = False
    return True

def fetch_databases(url):
    logging.info('\n\n fetch_databases >>>>>>>>>>>>> >>>>>>>>>>>>>>> %s' % url)
    database_list = get_db_list(url)
    visibility_dict = {'menu_items': False,
                        'text_field': False}
    if not database_list:
        visibility_dict['text_field'] = True
    elif len(database_list) == 1:
        global db
        db = database_list[0]
    else:
        visibility_dict['menu_items'] = database_list
    logging.info('\n\n visibility_dict >>>>>>>>>>>>> >>>>>>>>>>>>>>> %s' % visibility_dict)
    return visibility_dict

def get_db_list(url):
    logging.info('\n\n url >>>>>>>>>>>>>>> %s' % url)
    try:
        response = http.request('POST', url + "/web/database/list", body='{}', headers={'Content-type': 'application/json'})
        logging.debug('\n\n response --------> %s' % response)
        if response.status == 200:
            logging.info('\n\n response.data %s' % response.data)
            data = json.loads(response.data)
            return data['result']
        else:
            return []
    except Exception as e:
        return []
    return []

def login_odoo(selected_url, username, password_filled, database_dict):
    global db
    selected_db = db

    if database_dict['isTextInputVisible']:
        selected_db = database_dict['input_text']
    elif database_dict['isTextMenuVisible']:
        selected_db = database_dict['selected_db']
    if not selected_db and database_dict.get('input_text'):
        selected_db = database_dict.get('input_text')
    common = xmlrpc.client.ServerProxy('{}/xmlrpc/2/common'.format(selected_url))
    generated_uid = common.authenticate(selected_db, username, password_filled, {})
    db = selected_db
    global url
    url = selected_url
    global password
    password = password_filled
    if generated_uid:
        global uid
        uid = generated_uid
        models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(selected_url))
        user_name = models.execute_kw(selected_db, uid, password_filled,
                                  'res.users', 'read',
                                  [uid],
                                  {'fields': ['name']})
        logging.info('\n\n user_name >>>>>>>>>>>>> %s' % user_name)
        return {'result': 'pass', 'name_of_user': user_name[0]['name'], 'database': selected_db}
    return {'result': 'Fail'}

def fetch_options():
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    partner_ids = models.execute_kw(db, uid, password,
        'project.project', 'search',
        [[['parent_id', '=', False]]]
    )
    partners = models.execute_kw(db, uid, password,
        'project.project', 'read',
        [partner_ids],
        {'fields': ['name', 'child_ids']}
    )
    return partners

def fetch_options_sub_projects(selectedProject):
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    partner_ids = models.execute_kw(db, uid, password,
        'project.project', 'search',
        [[['parent_id', '=', int(selectedProject)]]]
    )
    partners = models.execute_kw(db, uid, password,
        'project.project', 'read',
        [partner_ids],
        {'fields': ['name']}
    )
    return partners

def fetch_projects(selected_url, username, password_filled, database_dict, last_modified=False):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    domain = [['parent_id', '=', False]]
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.append(['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    projects = models.execute_kw(db, uid, password,
        'project.project', 'search_read', [domain])
    domain = [['parent_id', '!=', False]]
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.append(['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    projects.extend(models.execute_kw(db, uid, password,
            'project.project', 'search_read', [domain]))
    return projects

def fetch_activity_type(selected_url, username, password_filled, database_dict, last_modified=False):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    domain = []
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.insert(0, ['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    activity_types = models.execute_kw(db, uid, password,
        'mail.activity.type', 'search_read', [domain])
    return activity_types

def create_timesheets(selected_url, username, password_filled, database_dict, timesheet_entries):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    records_list = []
    for entry in timesheet_entries:
        record_date = datetime.strptime(entry.get('record_date'), '%m/%d/%Y').strftime('%Y-%m-%d')
        vals = entry.get('unit_amount').split(':')
        t, hours = divmod(float(vals[0]), 24)
        t, minutes = divmod(float(vals[1]), 60)
        minutes = minutes / 60.0
        unit_amount = hours + minutes
        if isinstance(entry.get('odoo_record_id'), int) or isinstance(entry.get('odoo_record_id'), float):
            records_list.append({'local_record_id': entry.get('local_record_id'), 'odoo_record_id': entry.get('odoo_record_id')})
            models.execute_kw(db, uid, password, 'account.analytic.line', 'write',
                            [[int(entry.get('odoo_record_id'))], 
                            {'date_time': record_date, 
                            'project_id': int(entry.get('project_id')), 
                            'task_id': int(entry.get('task_id')), 
                            'name': entry.get('name'), 
                            'unit_amount': unit_amount}])
        else:
            record_id = models.execute_kw(db, uid, password, 'account.analytic.line', 'create',
                            [{'date_time': record_date, 
                            'project_id': int(entry.get('project_id')), 
                            'task_id': int(entry.get('task_id')), 
                            'name': entry.get('name'), 
                            'unit_amount': unit_amount}])
            records_list.append({'local_record_id': entry.get('local_record_id'), 'odoo_record_id': record_id})
    return records_list

def create_activities(selected_url, username, password_filled, database_dict, activity_entries):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    records_list = []
    for entry in activity_entries:
        if not entry.get('due_date'):
            continue
        record_date = datetime.strptime(entry.get('due_date'), '%m/%d/%Y').strftime('%Y-%m-%d')
        if not isinstance(entry.get('odoo_record_id'), int) or not isinstance(entry.get('odoo_record_id'), float):
            models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(selected_url))
            model = 'res.partner'
            res_id = False
            if int(entry.get('link_id', 0)) == 1:
                model = 'project.project'
                res_id = int(entry.get('project_id'))
            elif int(entry.get('link_id', 0)) == 2:
                model = 'project.task'
                res_id = int(entry.get('task_id'))
            elif int(entry.get('link_id', 0)) == 3:
                model = entry.get('res_model')
                res_id = int(entry.get('res_id'))
            else:
                user_name = models.execute_kw(db, uid, password,
                                          'res.users', 'read',
                                          [int(entry.get('user_id'))],
                                          {'fields': ['partner_id']})
                res_id = user_name[0]['partner_id'][0]
            returned_default = models.execute_kw(db, uid, password, 'mail.activity', 'default_get', [['res_model', 'res_model_id']], {'context': {'default_res_model': model}})
            record_id = models.execute_kw(db, uid, password, 'mail.activity', 'create',
                            [
                            {'date_deadline': record_date, 
                            'activity_type_id': int(entry.get('activity_type_id')), 
                            'summary': entry.get('summary'), 
                            'note': entry.get('notes'), 
                            'user_id': int(entry.get('user_id')),
                            'res_model_id': returned_default['res_model_id'],
                            'res_id': res_id
                            }])
            records_list.append({'local_record_id': entry.get('local_record_id'),
                     'odoo_record_id': record_id})
    return records_list

def fetch_tasks(selected_url, username, password_filled, database_dict, last_modified=False):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    domain = [['parent_id', '=', False]]
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.append(['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    tasks = models.execute_kw(db, uid, password,
        'project.task', 'search_read', [domain])
    domain = [['parent_id', '!=', False]]
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.append(['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    tasks.extend(models.execute_kw(db, uid, password,
            'project.task', 'search_read', [domain]))
    return tasks

def fetch_contacts(selected_url, username, password_filled, database_dict, last_modified=False):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    domain = []
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.append(['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
    contacts = models.execute_kw(db, uid, password, 'res.users', 'search', [domain])
    contacts = models.execute_kw(db, uid, password, 'res.users', 'read', [contacts], {'fields': ['name']})
    return contacts

# def update_projects(selected_url, username, password_filled, database_dict):
#     response = login_odoo(selected_url, username, password_filled, database_dict)
#     models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
#     projects = models.execute_kw(db, uid, password,
#         'project.project', 'search_read', [])
#     return projects

def update_tasks(selected_url, username, password_filled, database_dict, tasks_data):
    # response = login_odoo(selected_url, username, password_filled, database_dict)
    # models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    # tasks = models.execute_kw(db, uid, password,
    #     'project.task', 'search_read', [])
    # return tasks
    return True

def fetch_options_tasks(selectedProject):

    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    
    partner_ids = models.execute_kw(db, uid, password,
        'project.task', 'search',
        [[['project_id', '=', int(selectedProject)], ['parent_id', '=', False]]]
    )
    partners = models.execute_kw(db, uid, password,
        'project.task', 'read',
        [partner_ids],
        {'fields': ['name', 'child_ids']}
    )
    return partners

def fetch_options_sub_tasks(selected_task):
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    
    partner_ids = models.execute_kw(db, uid, password,
        'project.task', 'search',
        [[['parent_id', '=', int(selected_task)]]]
    )
    partners = models.execute_kw(db, uid, password,
        'project.task', 'read',
        [partner_ids],
        {'fields': ['name']}
    )
    return partners

def fetch_activities(selected_url, username, password_filled, database_dict, last_modified=False):
    response = login_odoo(selected_url, username, password_filled, database_dict)
    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    domain = ['|', ['user_id', '=', uid], ['create_uid', '=', uid]]
    if last_modified:
        formatted_date = datetime.strptime(last_modified[:-1], '%Y-%m-%dT%H:%M:%S.%f')
        domain.insert(0, ['write_date', '>=', formatted_date.strftime('%Y-%m-%d %H:%M:%S')])
        # domain.insert(0, ['write_date', '>=', datetime.fromisoformat(last_modified).strftime('%Y-%m-%d %H:%M:%S')])
    activities_search = models.execute_kw(db, uid, password,
        'mail.activity', 'search',
        [domain])
    activities = models.execute_kw(db, uid, password,
        'mail.activity', 'read', [activities_search],
        {'fields': ['date_deadline', 'activity_type_id', 'summary', 'note', 'res_model', 'res_id', 'user_id']})
    return activities

def save_timesheet_entries(timesheet_entries):

    models = xmlrpc.client.ServerProxy('{}/xmlrpc/2/object'.format(url))
    entry_vals = []
    timesheet_entries = '%s' % timesheet_entries
    entry_list = json.loads(timesheet_entries)
    for entry in entry_list:

        formatted_date = False
        if entry.get('dateTime'):
            date_obj = datetime.strptime(entry.get('dateTime'), '%m/%d/%Y')  # Parse date string to datetime object
            formatted_date = date_obj.strftime('%Y-%m-%d')
        time_float = False
        spent_duration = False
        if entry.get('spenthours') and not entry['isManualTimeRecord']:
            spent_duration = entry.get('spenthours')
            hour, minute,sacnd = spent_duration.split(':')
            spent_duration = f"{hour}:{minute}"
        elif entry.get('manualSpentHours') and entry['isManualTimeRecord']:
            spent_duration = entry.get('manualSpentHours')
        if spent_duration:
            hours, minutes = spent_duration.split(':')
            hours = int(hours)
            minutes = int(minutes)
            time_float = hours + minutes / 60.0
        prepared_vals = {
            'date': formatted_date,
            'project_id': entry.get('project'),
            # 'task_id': task[0],
            'name': entry.get('description'),
            'unit_amount': time_float
        }
        if entry.get('subTask', 0) > 0:
            prepared_vals.update({'task_id': entry.get('subTask')})
        else:
            prepared_vals.update({'task_id': entry.get('task')})

        entry_vals.append(prepared_vals)
    entries_timesheet = models.execute_kw(db, uid, password,
        'account.analytic.line', 'create',
        [entry_vals]
    )
    return True
