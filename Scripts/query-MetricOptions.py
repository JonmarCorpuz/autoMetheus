#!/usr/bin/python3

print("\033[37mThis is regular white text\033[0m")

# ==== FUNCTIONS =================================================================================================
def metricMenu(): 
    print("""
Available metrics:
[1] System Metrics 
[2] Application Metrics
[3] Kubernetes Metrics
    """) 
    metric = input("\033[1;33m[REQUIRED]\033[0m" + " Please enter a number to select the type of metric you'd like to collect: ")
    return metric

def systemMetricMenu():
    print("""
Available system metrics:
[1] CPU Metrics
[2] Memory Metrics
[3] Network Metrics
[4] Disk Metrics
[5] Process Metrics
[100] All Metrics
    """)
    systemMetric = input("\033[1;33m[REQUIRED]\033[0m" + " Please enter a number to select the metric you'd like to collect: ")
    return systemMetric

def applicationMetricMenu():
    print("""
Available application metrics:
[1] HTTP Metrics
[2] Database Metrics
[3] Cache Metrics
[4] Job Metrics
[5] Status Metrics
[100] All Metrics      
    """) 
    applicationMetric = input("\033[1;33m[REQUIRED]\033[0m" + " Please enter a number to select the metric you'd like to collect: ")
    return applicationMetric

def kubernetesMetricMenu():
    print("""
Available Kubernetes metrics:
[1] Pod-Level Metrics
[2] Container Metrics
[3] Node Metrics
[4] Workload Metrics
[5] API Server Metrics
[6] Scheduler Metrics
[7] Controller Metrics
[8] kubelet Metrics
[100] All Metrics 
    """) 
    kubernetesMetric = input("\033[1;33m[REQUIRED]\033[0m" + " Please enter a number to select the metric you'd like to collect: ")
    return kubernetesMetric

while True:

    selectedMetric = metricMenu()

    # ==== SYSTEM METRICS ============================================================================================
    if selectedMetric == "1":
        systemMetricMenu()
        print("tmp")

    # ==== APPLICATION METRICS =======================================================================================
    elif selectedMetric == "2":
        applicationMetricMenu()
        print("tmp")

    # ==== KUBERNETES METRICS ========================================================================================
    elif selectedMetric == "3":
        kubernetesMetricMenu()
        print("tmp")

    # ==== INVALID INPUT =============================================================================================
    else:
        print("\n\033[91m[ERROR]\033[0m" + f" {selectedMetric} is not a valid option. Please enter a valid option")
