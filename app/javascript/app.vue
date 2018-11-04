<template>
  <div id="app">
    <transition v-if="newTask.show">
      <section class="add_new_task_wrapper">
        <div class="add_new_task_inner">
          <div class="add_new_task_inner__btn_area">
            <button id="btn_cancel" v-on:click="cancelNewTask" type="button">閉じる</button>
            <span>新しいタスク</span>
            <button id="btn_add" v-on:click="addNewTask" type="button">追加する</button>
          </div>
          <div class="add_new_task_inner__input_area">
            <input v-model="newTask.title" type="text" name="title" placeholder="タスクタイトル" />
            <input v-model="newTask.startAt" type="datetime-local" name="start_at"/>
            <vue-google-autocomplete
              ref="newTask.place"
              id="map"
              name="place"
              classname="form-control"
              placeholder="場所"
              types=""
              country="jp"
              v-on:placechanged="getAddressData"
            >
            </vue-google-autocomplete>
            <input v-model="newTask.lat" type="hidden" name="lat" />
            <input v-model="newTask.lon" type="hidden" name="lon" />
            <input v-model="newTask.wether" type="hidden" name="wether" />
            <textarea v-model="newTask.detail" placeholder="メモ" class="" rows="4" cols="40" /></textarea>
          </div>
          <div class="suggest_location"></div>
        </div>
      </section>
    </transition>
    <section v-else class="add_new_task_btn">
      <button id="new_task" v-on:click="showNewTask">+</button>
    </section>
    <section v-cloak v-for="monthList in taskList" v-bind:id="monthList.month" class="task_wrapper">
      <h2 class="task_ym">{{monthList.month}}</h2>
      <ul>
        <li v-for="task in monthList.tasks" v-bind:id="'row_task_' + task.id" class="task_list">
          <div>{{task.start_at.slice(8, 10)}} : {{task.title}}</div>
        </li>
      </ul>
    </section>
    <section class="icon_loading" v-observe-visibility="visibilityChanged"><img v-show="isVisibleLoadicon" src="/images/icon_loader.gif"></section>
  </div>
</template>

<script>
import VueGoogleAutocomplete from 'vue-google-autocomplete'
import axios from 'axios';

const token = document.getElementsByName('csrf-token')[0].getAttribute('content')
axios.defaults.headers.common['X-CSRF-Token'] = token

export default {
  components: { VueGoogleAutocomplete },
  data: function () {
    return {
      newTask: {
        show: false,
        startAt: '',
        title: '',
        place: '',
        lat: '',
        lon: '',
        wether: '',
        detail: ''
      },
      isVisibleLoadicon: true,
      taskList: [],
      isActive: false
    }
  },
  mounted: function() {
    this.fetchTasks();
  },
  methods: {
    visibilityChanged: function(isVisibleLoadicon) {
      if (isVisibleLoadicon && this.$data.taskList.length > 0) {
        // 次のn件をロードする
        var monthArray = this.$data.taskList;
        var lastMonth = monthArray[monthArray.length - 1];
        var taskArray = lastMonth.tasks;
        var lastTask = taskArray[taskArray.length - 1];
        axios.get('/tasks/task_list', {
          params: {
            // this.$data.taskListの一番最後のtaskのstarAtとidを指定する
            next_start_at: lastTask.start_at,
            next_id: lastTask.id
          }
        }).then((response) => {
          if (Object.keys(response.data).length > 0) {
            this.updateTasks(response.data);
          } else {
            this.$data.isVisibleLoadicon = false
          }
        })
      }
    },
    getAddressData: function (addressData, placeResultData, id) {
      console.table(addressData);
      console.table(placeResultData);
      this.$data.newTask.lat = addressData.latitude;
      this.$data.newTask.lon = addressData.longitude;
    },
    addNewTask: function() {
      // api succese or error
      axios.post('/tasks/add_task', {
        task: {
          title: this.$data.newTask.title,
          place: this.$data.newTask.place,
          latitude: this.$data.newTask.lat,
          longitude: this.$data.newTask.lon,
          weather_infomation: this.$data.newTask.wether,
          detail: this.$data.newTask.detail,
          start_at: this.$data.newTask.startAt
        }
      }).then((response) => {
        if (response.data.success) {
          this.$data.newTask.title = '';
          this.$data.newTask.detail = '';
          this.$data.newTask.show = false;
          this.fetchTasks();
        } else {
          alert("error!")
        }
      });
    },
    cancelNewTask: function() {
      this.$data.newTask.show = false;
    },
    showNewTask: function(event) {
      this.$data.newTask.show = true;
    },
    updateTasks: function(taskArray) {
      for (var i in taskArray) {
        var task = taskArray[i];
        var month = task.start_at.slice(0, 7).replace('-', '/');

        var monthData = this.$data.taskList.find(function(element) {
          return element.month == month;
        });
      	if (typeof(monthData) == 'undefined') {
          monthData = { month: month, tasks: [] }
          this.$data.taskList.push(monthData);
      	}

        var foundIndex = monthData.tasks.findIndex(function(element) {
          return element.start_at > task.start_at;
        });
        if (foundIndex >= 0) {
          monthData.tasks.splice(foundIndex, 0, task);
        } else {
          monthData.tasks.push(task);
        }
      }
    },
    fetchTasks: function() {
      axios.get('/tasks/task_list').then((response) => {
        this.updateTasks(response.data);
      })
    }
  }
}

</script>

<style>

</style>
